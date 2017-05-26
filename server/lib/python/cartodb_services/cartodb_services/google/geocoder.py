#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import base64
import googlemaps

from exceptions import MalformedResult, InvalidGoogleCredentials


class GoogleMapsGeocoder:
    """A Google Maps Geocoder wrapper for python"""

    def __init__(self, client_id, client_secret, logger):
        if not self._valid_credentials(client_secret):
            raise InvalidGoogleCredentials('Invalid google secret key')
        self.client_id = self._clean_client_id(client_id)
        self.client_secret = client_secret
        self.geocoder = googlemaps.Client(
            client_id=self.client_id, client_secret=self.client_secret)
        self._logger = logger

    def geocode(self, searchtext, city=None, state=None,
                country=None):
        try:
            opt_params = self._build_optional_parameters(city, state, country)
            results = self.geocoder.geocode(address=searchtext,
                                            components=opt_params)
            if results:
                return self._extract_lng_lat_from_result(results[0])
            else:
                return []
        except KeyError:
            raise MalformedResult()

    def _extract_lng_lat_from_result(self, result):
        location = result['geometry']['location']
        longitude = location['lng']
        latitude = location['lat']
        return [longitude, latitude]

    def _build_optional_parameters(self, city=None, state=None,
                                   country=None):
        optional_params = {}
        if city:
            optional_params['locality'] = city
        if state:
            optional_params['administrative_area'] = state
        if country:
            optional_params['country'] = country
        return optional_params

    def _clean_client_id(self, client_id):
        # Consistency with how the client_id is saved in metadata
        return client_id.replace('client=', '')

    def _valid_credentials(self, private_key):
        try:
            # Only fails if the string dont have a correct padding for b64
            # but this way we could provide a more clear error than
            # TypeError: Incorrect padding
            base64.b64decode(private_key)
            return True
        except TypeError:
            return False

#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps

from exceptions import MalformedResult


class Geocoder:
    """A Google Maps Geocoder wrapper for python"""

    def __init__(self, client_id, client_secret):
        self.client_id = self._clean_client_id(client_id)
        self.client_secret = client_secret
        self.geocoder = googlemaps.Client(
            client_id=self.client_id, client_secret=self.client_secret)

    def geocode_address(self, searchtext, city=None, state=None,
                        country=None):
        opt_params = self._build_optional_parameters(city, state, country)
        results = self.geocoder.geocode(address=searchtext, components=opt_params)
        if results:
            return self._extract_lng_lat_from_result(results[0])
        else:
            return []

    def _extract_lng_lat_from_result(self, result):
        try:
            location = result['geometry']['location']
            longitude = location['lng']
            latitude = location['lat']
            return [longitude, latitude]
        except KeyError:
            raise MalformedResult()

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

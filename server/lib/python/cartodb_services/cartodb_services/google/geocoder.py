#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps
from urlparse import parse_qs

from exceptions import MalformedResult
from cartodb_services.google.exceptions import InvalidGoogleCredentials
from client_factory import GoogleMapsClientFactory


class GoogleMapsGeocoder:
    """A Google Maps Geocoder wrapper for python"""

    def __init__(self, client_id, client_secret, logger):
        if client_id is None:
            raise InvalidGoogleCredentials
        arguments = parse_qs(client_id)
        self.client_id = arguments['client'] if arguments.has_key('client') else client_id
        self.client_secret = client_secret
        self.channel = arguments['channel'] if arguments.has_key('channel') else None
        self.geocoder = GoogleMapsClientFactory.get(self.client_id, self.client_secret, self.channel)
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

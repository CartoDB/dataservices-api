#!/usr/local/bin/python
# -*- coding: utf-8 -*-

from urlparse import parse_qs

from exceptions import MalformedResult
from cartodb_services.geocoder import compose_address
from cartodb_services.google.exceptions import InvalidGoogleCredentials
from client_factory import GoogleMapsClientFactory

EMPTY_RESPONSE = [[], {}]
PARTIAL_FACTOR = 0.8
RELEVANCE_BY_LOCATION_TYPE = {
    'ROOFTOP': 1,
    'GEOMETRIC_CENTER': 0.9,
    'RANGE_INTERPOLATED': 0.8,
    'APPROXIMATE': 0.7
}


class GoogleMapsGeocoder():

    def __init__(self, client_id, client_secret, logger):
        if client_id is None:
            raise InvalidGoogleCredentials
        self.client_id, self.channel = self.parse_client_id(client_id)
        self.client_secret = client_secret
        self.geocoder = GoogleMapsClientFactory.get(self.client_id, self.client_secret, self.channel)
        self._logger = logger

    def geocode(self, searchtext, city=None, state=None, country=None):
        return self.geocode_meta(searchtext, city, state, country)[0]

    def geocode_meta(self, searchtext, city=None, state=None, country=None):
        address = compose_address(searchtext, city, state, country)
        try:
            opt_params = self._build_optional_parameters(city, state, country)
            results = self.geocoder.geocode(address=address,
                                            components=opt_params)
            return self._process_results(results)
        except KeyError as e:
            self._logger.error('address: {}'.format(address), e)
            raise MalformedResult()

    def _process_results(self, results):
        if results:
            self._logger.debug('--> results: {}'.format(results[0]))
            return [
                self._extract_lng_lat_from_result(results[0]),
                self._extract_metadata_from_result(results[0])
            ]
        else:
            return EMPTY_RESPONSE

    def _extract_lng_lat_from_result(self, result):
        location = result['geometry']['location']
        longitude = location['lng']
        latitude = location['lat']
        return [longitude, latitude]

    def _extract_metadata_from_result(self, result):
        location_type = result['geometry']['location_type']
        base_relevance = RELEVANCE_BY_LOCATION_TYPE[location_type]
        partial_match = result.get('partial_match', False)
        partial_factor = PARTIAL_FACTOR if partial_match else 1
        return {
            'relevance': base_relevance * partial_factor
        }


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

    def parse_client_id(self, client_id):
        arguments = parse_qs(client_id)
        client = arguments['client'][0] if arguments.has_key('client') else client_id
        channel = arguments['channel'][0] if arguments.has_key('channel') else None
        return client, channel

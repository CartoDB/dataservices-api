#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
import requests
from uritemplate import URITemplate
from cartodb_services.metrics import Traceable
from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry
from cartodb_services.tools.normalize import normalize

HOST = 'https://api.tomtom.com'
API_BASEURI = '/search/2'
REQUEST_BASEURI = ('/geocode/'
               '{searchtext}.json'
               '?limit=1')
ENTRY_RESULTS = 'results'
ENTRY_POSITION = 'position'
ENTRY_LON = 'lon'
ENTRY_LAT = 'lat'
EMPTY_RESPONSE = [[], {}]


class TomTomGeocoder(Traceable):
    '''
    Python wrapper for the TomTom Geocoder service.
    '''

    def __init__(self, apikey, logger, service_params=None):
        service_params = service_params or {}
        self._apikey = apikey
        self._logger = logger

    def _uri(self, searchtext, country=None):
        return HOST + API_BASEURI + \
               self._request_uri(searchtext, country, self._apikey)

    def _request_uri(self, searchtext, country=None, apiKey=None):
        baseuri = REQUEST_BASEURI
        if country:
            baseuri += '&countrySet={}'.format(country)
        baseuri = baseuri + '&key={apiKey}' if apiKey else baseuri
        return URITemplate(baseuri).expand(apiKey=apiKey,
                                           searchtext=searchtext.encode('utf-8'))

    def _extract_lng_lat_from_feature(self, result):
        position = result[ENTRY_POSITION]
        longitude = position[ENTRY_LON]
        latitude = position[ENTRY_LAT]
        return [longitude, latitude]

    def _validate_input(self, searchtext, city=None, state_province=None,
                        country=None):
        if searchtext and searchtext.strip():
            return True
        elif city:
            return True
        elif state_province:
            return True

        return False

    @qps_retry(qps=5)
    def geocode(self, searchtext, city=None, state_province=None,
                country=None):
        return self.geocode_meta(searchtext, city, state_province, country)[0]

    @qps_retry(qps=5)
    def geocode_meta(self, searchtext, city=None, state_province=None,
                country=None):
        if searchtext:
            searchtext = searchtext.decode('utf-8')
        if city:
            city = city.decode('utf-8')
        if state_province:
            state_province = state_province.decode('utf-8')
        if country:
            country = country.decode('utf-8')

        if not self._validate_input(searchtext, city, state_province, country):
            return EMPTY_RESPONSE

        address = []
        if searchtext and searchtext.strip():
            address.append(normalize(searchtext))
        if city:
            address.append(normalize(city))
        if state_province:
            address.append(normalize(state_province))

        uri = self._uri(searchtext=', '.join(address), country=country)

        try:
            response = requests.get(uri)
            return self._parse_response(response.status_code, response.text)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to TomTom geocoding server',
                               te)
            raise ServiceException('Error geocoding {0} using TomTom'.format(
                searchtext), None)
        except requests.ConnectionError as ce:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to TomTom geocoding server',
                               exception=ce)
            return EMPTY_RESPONSE

    def _parse_response(self, status_code, text):
        if status_code == requests.codes.ok:
            return self._parse_geocoder_response(text)
        elif status_code == requests.codes.bad_request:
            return EMPTY_RESPONSE
        elif status_code == requests.codes.unprocessable_entity:
            return EMPTY_RESPONSE
        else:
            msg = 'Unknown response {}: {}'.format(str(status_code), text)
            raise ServiceException(msg, None)

    def _parse_geocoder_response(self, response):
        json_response = json.loads(response) \
            if type(response) != dict else response

        if json_response and json_response[ENTRY_RESULTS]:
            result = json_response[ENTRY_RESULTS][0]
            return [
                self._extract_lng_lat_from_feature(result),
                self._extract_metadata_from_result(result)
            ]
        else:
            return EMPTY_RESPONSE

    def _extract_metadata_from_result(self, result):
        return {
            'relevance': result['score']  # TODO: normalize
        }

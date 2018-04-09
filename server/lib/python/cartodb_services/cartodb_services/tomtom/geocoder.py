#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
import requests
from uritemplate import URITemplate
from cartodb_services.metrics import Traceable
from cartodb_services.tools.exceptions import ServiceException
from cartodb_services.tools.qps import qps_retry
from cartodb_services.tools.normalize import normalize

BASEURI = ('https://api.tomtom.com/search/2/geocode/'
           '{searchtext}.JSON'
           '?key={apiKey}'
           '&limit=1')
ENTRY_RESULTS = 'results'
ENTRY_POSITION = 'position'
ENTRY_LON = 'lon'
ENTRY_LAT = 'lat'


class TomTomGeocoder(Traceable):
    '''
    Python wrapper for the TomTom Geocoder service.
    '''

    def __init__(self, apikey, logger, service_params=None):
        service_params = service_params or {}
        self._apikey = apikey
        self._logger = logger

    def _uri(self, searchtext, countries=None):
        baseuri = BASEURI + '&countrySet={}'.format(countries) \
                  if countries else BASEURI
        uri = URITemplate(baseuri).expand(apiKey=self._apikey,
                                          searchtext=searchtext.encode('utf-8'))
        return uri

    def _parse_geocoder_response(self, response):
        json_response = json.loads(response)

        if json_response and json_response[ENTRY_RESULTS]:
            result = json_response[ENTRY_RESULTS][0]
            return self._extract_lng_lat_from_feature(result)
        else:
            return []

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
        if searchtext:
            searchtext = searchtext.decode('utf-8')
        if city:
            city = city.decode('utf-8')
        if state_province:
            state_province = state_province.decode('utf-8')
        if country:
            country = country.decode('utf-8')

        if not self._validate_input(searchtext, city, state_province, country):
            return []

        address = []
        if searchtext and searchtext.strip():
            address.append(normalize(searchtext))
        if city:
            address.append(normalize(city))
        if state_province:
            address.append(normalize(state_province))

        uri = self._uri(searchtext=', '.join(address), countries=country)

        try:
            response = requests.get(uri)

            if response.status_code == requests.codes.ok:
                return self._parse_geocoder_response(response.text)
            elif response.status_code == requests.codes.bad_request:
                return []
            elif response.status_code == requests.codes.unprocessable_entity:
                return []
            else:
                raise ServiceException(response.status_code, response)
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
            return []

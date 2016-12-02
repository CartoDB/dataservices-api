#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
import requests

from requests.adapters import HTTPAdapter
from exceptions import *
from cartodb_services.metrics import Traceable


class HereMapsGeocoder(Traceable):
    'A Here Maps Geocoder wrapper for python'

    PRODUCTION_GEOCODE_JSON_URL = 'https://geocoder.api.here.com/6.2/geocode.json'
    STAGING_GEOCODE_JSON_URL = 'https://geocoder.cit.api.here.com/6.2/geocode.json'
    DEFAULT_MAXRESULTS = 1
    DEFAULT_GEN = 9
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES=3

    ADDRESS_PARAMS = [
        'city',
        'country',
        'county',
        'district',
        'housenumber',
        'postalcode',
        'searchtext',
        'state',
        'street'
        ]

    ADMITTED_PARAMS = [
        'additionaldata',
        'app_id',
        'app_code',
        'bbox',
        'countryfocus',
        'gen',
        'jsonattributes',
        'jsoncallback',
        'language',
        'locationattributes',
        'locationid',
        'mapview',
        'maxresults',
        'pageinformation',
        'politicalview',
        'prox',
        'strictlanguagemode'
        ] + ADDRESS_PARAMS

    def __init__(self, app_id, app_code, logger, maxresults=DEFAULT_MAXRESULTS,
                 gen=DEFAULT_GEN, host=PRODUCTION_GEOCODE_JSON_URL):
        self.app_id = app_id
        self.app_code = app_code
        self._logger = logger
        self.maxresults = maxresults
        self.gen = gen
        self.host = host

    def geocode(self, **kwargs):
        params = {}
        for key, value in kwargs.iteritems():
            if value:
                params[key] = value
        if not params:
            raise NoGeocodingParams()
        return self._execute_geocode(params)

    def _execute_geocode(self, params):
        if not set(params.keys()).issubset(set(self.ADDRESS_PARAMS)):
            raise BadGeocodingParams(params)
        try:
            response = self._perform_request(params)
            results = response['Response']['View'][0]['Result'][0]
            return self._extract_lng_lat_from_result(results)
        except IndexError:
            return []
        except KeyError:
            raise MalformedResult()

    def _perform_request(self, params):
        request_params = {
            'app_id': self.app_id,
            'app_code': self.app_code,
            'maxresults': self.maxresults,
            'gen': self.gen
        }
        request_params.update(params)
        # TODO Extract HTTP client wrapper
        session = requests.Session()
        session.mount(self.host, HTTPAdapter(self.MAX_RETRIES))
        response = session.get(self.host, params=request_params,
                                timeout=(self.CONNECT_TIMEOUT, self.READ_TIMEOUT))
        self.add_response_data(response, self._logger)
        if response.status_code == requests.codes.ok:
            return json.loads(response.text)
        elif response.status_code == requests.codes.bad_request:
            self._logger.warning('Error 4xx trying to geocode street using HERE',
                               data={"response": response.json(), "params":
                                     params})
            return []
        else:
            self._logger.error('Error trying to geocode street using HERE',
                               data={"response": response.json(), "params":
                                     params})
            raise Exception('Error trying to geocode street using Here')

    def _extract_lng_lat_from_result(self, result):
        location = result['Location']
        longitude = location['DisplayPosition']['Longitude']
        latitude = location['DisplayPosition']['Latitude']

        return [longitude, latitude]

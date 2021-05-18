#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
import requests

from requests.adapters import HTTPAdapter
from exceptions import *
from cartodb_services.geocoder import PRECISION_PRECISE, PRECISION_INTERPOLATED, geocoder_metadata, EMPTY_RESPONSE
from cartodb_services.metrics import Traceable
from cartodb_services.tools.country import country_to_iso3

class HereMapsGeocoder(Traceable):
    'A Here Maps v6 Geocoder wrapper for python'

    PRODUCTION_GEOCODE_JSON_URL = 'https://geocoder.api.here.com/6.2/geocode.json'
    STAGING_GEOCODE_JSON_URL = 'https://geocoder.cit.api.here.com/6.2/geocode.json'
    DEFAULT_MAXRESULTS = 1
    DEFAULT_GEN = 9
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES=1

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

    PRECISION_BY_MATCH_TYPE = {
        'pointAddress': PRECISION_PRECISE,
        'interpolated': PRECISION_INTERPOLATED
    }
    MATCH_TYPE_BY_MATCH_LEVEL = {
        'landmark': 'point_of_interest',
        'country': 'country',
        'state': 'state',
        'county': 'county',
        'city': 'locality',
        'district': 'district',
        'street': 'street',
        'intersection': 'intersection',
        'houseNumber': 'street_number',
        'postalCode': 'postal_code'
    }

    def __init__(self, app_id, app_code, logger, service_params=None, maxresults=DEFAULT_MAXRESULTS):
        service_params = service_params or {}
        self.app_id = app_id
        self.app_code = app_code
        self._logger = logger
        self.maxresults = maxresults
        self.gen = service_params.get('gen', self.DEFAULT_GEN)
        self.host = service_params.get('json_url', self.PRODUCTION_GEOCODE_JSON_URL)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)

    def geocode(self, **kwargs):
        return self.geocode_meta(**kwargs)[0]

    def geocode_meta(self, **kwargs):
        params = {}
        for key, value in kwargs.iteritems():
            if value and value.strip():
                params[key] = value
        if not params:
            return EMPTY_RESPONSE
        return self._execute_geocode(params)

    def _execute_geocode(self, params):
        if not set(params.keys()).issubset(set(self.ADDRESS_PARAMS)):
            raise BadGeocodingParams(params)
        try:
            response = self._perform_request(params)
            result = response['Response']['View'][0]['Result'][0]
            return [self._extract_lng_lat_from_result(result),
                    self._extract_metadata_from_result(result)]
        except IndexError:
            return EMPTY_RESPONSE
        except KeyError as e:
            self._logger.error('params: {}'.format(params), e)
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
        session.mount(self.host, HTTPAdapter(max_retries=self.max_retries))
        response = session.get(self.host, params=request_params,
                                timeout=(self.connect_timeout, self.read_timeout))
        self.add_response_data(response, self._logger)
        if response.status_code == requests.codes.ok:
            return json.loads(response.text)
        elif response.status_code == requests.codes.bad_request:
            self._logger.warning('Error 4xx trying to geocode street using HERE',
                               data={"response": response.json(), "params":
                                     params})
            return EMPTY_RESPONSE
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

    def _extract_metadata_from_result(self, result):
        # See https://stackoverflow.com/questions/51285622/missing-matchtype-at-here-geocoding-responses
        precision = self.PRECISION_BY_MATCH_TYPE.get(
            result.get('MatchType'), PRECISION_INTERPOLATED)
        match_type = self.MATCH_TYPE_BY_MATCH_LEVEL.get(result['MatchLevel'], None)
        return geocoder_metadata(
            result['Relevance'],
            precision,
            [match_type] if match_type else []
        )

class HereMapsGeocoderV7(Traceable):
    'A Here Maps Geocoder v7 wrapper for python'

    PRODUCTION_GEOCODE_JSON_URL = 'https://geocode.search.hereapi.com/v1/geocode'
    DEFAULT_MAXRESULTS = 1
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES=1
    COUNTRY_ISO3_LENGTH = 3

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

    QUALIFIED_PARAMS = [
        'state', 
        'city', 
        'county', 
        'district', 
        'postalcode', 
        'housenumber', 
        'street'
        ]

    PRECISION_BY_MATCH_TYPE = {
        'pointAddress': PRECISION_PRECISE,
        'interpolated': PRECISION_INTERPOLATED
    }
    MATCH_TYPE_BY_MATCH_LEVEL = {
        'landmark': 'point_of_interest',
        'country': 'country',
        'state': 'state',
        'county': 'county',
        'city': 'locality',
        'district': 'district',
        'street': 'street',
        'intersection': 'intersection',
        'houseNumber': 'street_number',
        'postalCode': 'postal_code'
    }

    def __init__(self, apikey, logger, service_params=None, limit=DEFAULT_MAXRESULTS):
        service_params = service_params or {}
        self.apikey = apikey
        self._logger = logger
        self.limit = limit
        self.host = service_params.get('json_url', self.PRODUCTION_GEOCODE_JSON_URL)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)

    def geocode(self, **kwargs):
        return self.geocode_meta(**kwargs)[0]

    def geocode_meta(self, **kwargs):
        params = {}
        for key, value in kwargs.iteritems():
            if value and value.strip():
                params[key] = value
        if not params:
            return EMPTY_RESPONSE
        return self._execute_geocode(params)

    def _execute_geocode(self, params):
        if not set(params.keys()).issubset(set(self.ADDRESS_PARAMS)):
            raise BadGeocodingParams(params)
        try:
            response = self._perform_request(params)
            result = response['items'][0]
            return [self._extract_lng_lat_from_result(result),
                    self._extract_metadata_from_result(result)]
        except IndexError:
            return EMPTY_RESPONSE
        except KeyError as e:
            self._logger.error('params: {}'.format(params), e)
            raise MalformedResult()

    def _get_v7param(self, param, reverse=False):
        mapping = {
            'city': 'city',
            'country': 'in',
            'county': 'county',
            'district': 'district',
            'housenumber': 'houseNumber',
            'postalcode': 'postalCode',
            'state': 'state',
            'street': 'street',
            'searchtext': 'q'
        }

        if reverse is True:
            mapping = {v:k for k,v in mapping.items()}

        return mapping.get(param)

    def _is_iso3_country(self, country):
        return len(country) == self.COUNTRY_ISO3_LENGTH

    def _parse_country(self, country):
        country_iso3 = country_to_iso3(country) or country
        
        parsed_country = "countryCode:{0}".format(country_iso3) if (country_iso3 and self._is_iso3_country(country_iso3)) else None

        return parsed_country

    def _get_qq(self, params):
        qualified_params = ['{0}={1}'.format(self._get_v7param(k), v) for k,v in params.items() if k in self.QUALIFIED_PARAMS]

        qq = '&'.join(qualified_params) if qualified_params else None

        return qq

    def _parse_params(self, params):
        country, q = (params.get(value) for value in ('country', 'searchtext'))

        parsed_params = {'q': q}

        qq = self._get_qq(params)
        
        parsed_country = self._parse_country(country)

        parsed_params.update({k:v for k, v in (('qq', qq), ('in', parsed_country)) if v is not None})

        return parsed_params

    def _perform_request(self, params):
        request_params = {
            'apikey': self.apikey,
            'limit': self.limit,
        }
        parsed_params = self._parse_params(params)
        request_params.update(parsed_params)
        # TODO Extract HTTP client wrapper
        session = requests.Session()
        session.mount(self.host, HTTPAdapter(max_retries=self.max_retries))
        response = session.get(self.host, params=request_params,
                                timeout=(self.connect_timeout, self.read_timeout))
        self.add_response_data(response, self._logger)
        if response.status_code == requests.codes.ok:
            return json.loads(response.text)
        elif response.status_code == requests.codes.bad_request:
            self._logger.warning('Error 4xx trying to geocode street using HERE',
                               data={"response": response.json(), "params":
                                     parsed_params})
            return EMPTY_RESPONSE
        else:
            self._logger.error('Error trying to geocode street using HERE',
                               data={"response": response.json(), "params":
                                     parsed_params})
            raise Exception('Error trying to geocode street using Here')


    def _extract_lng_lat_from_result(self, result):
        position = result['position']
        longitude = position['lng']
        latitude = position['lat']

        return [longitude, latitude]

    def _extract_metadata_from_result(self, result):
        # See https://stackoverflow.com/questions/51285622/missing-matchtype-at-here-geocoding-responses
        precision = self.PRECISION_BY_MATCH_TYPE.get(
            result.get('resultType'), PRECISION_INTERPOLATED)
        match_type = self.MATCH_TYPE_BY_MATCH_LEVEL.get(result.get('resultType'), None)
        return geocoder_metadata(
            result['scoring']['queryScore'],
            precision,
            [match_type] if match_type else []
        )
import requests
import json
import re

from requests.adapters import HTTPAdapter
from cartodb_services.tools.exceptions import (WrongParams,
                                               MalformedResult,
                                               ServiceException)
from cartodb_services.tools.qps import qps_retry
from cartodb_services.tools import Coordinate, PolyLine
from cartodb_services.metrics import Traceable


class MapzenGeocoder(Traceable):
    'A Mapzen Geocoder wrapper for python'

    BASE_URL = 'https://search.mapzen.com/v1/search'
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1

    def __init__(self, app_key, logger, service_params=None):
        service_params = service_params or {}
        self._app_key = app_key
        self._url = service_params.get('base_url', self.BASE_URL)
        self._connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self._read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self._max_retries = service_params.get('max_retries', self.MAX_RETRIES)
        self._logger = logger

    @qps_retry(qps=20)
    def geocode(self, searchtext, city=None, state_province=None,
                country=None, search_type=None):

        # Remove the search_type if its address from the params sent to mapzen
        if search_type and search_type.lower() == 'address':
            search_type = None

        request_params = self._build_requests_parameters(searchtext, city,
                                                         state_province,
                                                         country, search_type)
        try:
            # TODO Extract HTTP client wrapper
            session = requests.Session()
            session.mount(self._url, HTTPAdapter(max_retries=self._max_retries))
            response = session.get(self._url, params=request_params,
                                    timeout=(self._connect_timeout, self._read_timeout))
            self.add_response_data(response, self._logger)
            if response.status_code == requests.codes.ok:
                return self.__parse_response(response.text)
            elif response.status_code == requests.codes.bad_request:
                return []
            else:
                self._logger.error('Error trying to geocode using mapzen',
                                data={"response_status": response.status_code,
                                      "response_reason": response.reason,
                                      "response_content": response.text,
                                      "reponse_url": response.url,
                                      "response_headers": response.headers,
                                      "searchtext": searchtext,
                                      "city": city, "country": country,
                                      "state_province": state_province})
                raise ServiceException('Error trying to geocode {0} using mapzen'.format(searchtext),
                                       response)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to Mapzen geocoding server', te)
            raise ServiceException('Error trying to geocode {0} using mapzen'.format(searchtext),
                                    None)
        except requests.ConnectionError as e:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to Mapzen geocoding server',
                               exception=e)
            return []

    def _build_requests_parameters(self, searchtext, city=None,
                                   state_province=None, country=None,
                                   search_type=None):
        request_params = {}
        search_string = self._build_search_text(searchtext.strip(),
                                                city,
                                                state_province)
        request_params['text'] = search_string
        request_params['api_key'] = self._app_key
        if search_type:
            request_params['layers'] = search_type
        if country:
            request_params['boundary.country'] = country
        return request_params

    def _build_search_text(self, searchtext, city, state_province):
        search_string = searchtext
        if city:
            search_string = "{0}, {1}".format(search_string, city)
        if state_province:
            search_string = "{0}, {1}".format(search_string, state_province)

        return search_string

    def __parse_response(self, response):
        try:
            parsed_json_response = json.loads(response)
            feature = parsed_json_response['features'][0]
            return self._extract_lng_lat_from_result(feature)
        except IndexError:
            return []
        except KeyError:
            raise MalformedResult()

    def _extract_lng_lat_from_result(self, result):
        location = result['geometry']['coordinates']
        longitude = location[0]
        latitude = location[1]
        return [longitude, latitude]

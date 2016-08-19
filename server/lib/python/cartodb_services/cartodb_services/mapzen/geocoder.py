import requests
import json
import re

from exceptions import WrongParams, MalformedResult
from qps import qps_retry
from cartodb_services.tools import Coordinate, PolyLine


class MapzenGeocoder:
    'A Mapzen Geocoder wrapper for python'

    BASE_URL = 'https://search.mapzen.com/v1/search'

    def __init__(self, app_key, logger, base_url=BASE_URL):
        self._app_key = app_key
        self._url = base_url
        self._logger = logger

    @qps_retry
    def geocode(self, searchtext, city=None, state_province=None, country=None):
        request_params = self._build_requests_parameters(searchtext, city,
                                                         state_province,
                                                         country)
        try:
            response = requests.get(self._url, params=request_params)
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
                                        "state_province": state_province })
                raise Exception('Error trying to geocode {0} using mapzen'.format(searchtext))
        except requests.ConnectionError as e:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to Mapzen geocoding server',
                               exception=e)
            return []


    def _build_requests_parameters(self, searchtext, city=None,
                                   state_province=None, country=None):
        request_params = {}
        search_string = self._build_search_text(searchtext.strip(),
                                                city,
                                                state_province)
        request_params['text'] = search_string
        request_params['layers'] = 'address'
        request_params['api_key'] = self._app_key
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

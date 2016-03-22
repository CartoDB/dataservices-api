import requests
import json
import re

from exceptions import WrongParams, MalformedResult
from qps import qps_retry
from cartodb_services.tools import Coordinate, PolyLine


class MapzenGeocoder:
    'A Mapzen Geocoder wrapper for python'

    BASE_URL = 'https://search.mapzen.com/v1/search'

    def __init__(self, app_key, base_url=BASE_URL):
        self._app_key = app_key
        self._url = base_url

    @qps_retry
    def geocode(self, searchtext, country=None):
        request_params = self._build_requests_parameters(searchtext, country)
        response = requests.get(self._url, params=request_params)
        if response.status_code == requests.codes.ok:
            return self.__parse_response(response.text)
        elif response.status_code == requests.codes.bad_request:
            return []
        else:
            response.raise_for_status()

    def _build_requests_parameters(self, searchtext, country=None):
        request_params = {}
        request_params['text'] = searchtext
        request_params['layers'] = 'address'
        request_params['api_key'] = self._app_key
        if country:
            request_params['boundary.country'] = country
        return request_params

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

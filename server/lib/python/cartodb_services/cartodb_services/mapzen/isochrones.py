import requests
import json
import re

from requests.adapters import HTTPAdapter
from exceptions import WrongParams, MalformedResult, ServiceException
from qps import qps_retry


class MapzenIsochrones:
    'A Mapzen Isochrones wrapper for python'

    BASE_URL = 'https://matrix.mapzen.com/isochrone'
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1

    ACCEPTED_MODES = {
        "walk": "pedestrian",
        "car": "auto"
    }

    def __init__(self, app_key, logger, service_params=None):
        service_params = service_params or {}
        self._app_key = app_key
        self._logger = logger
        self._url = service_params.get('base_url', self.BASE_URL)
        self._connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self._read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self._max_retries = service_params.get('max_retries', self.MAX_RETRIES)


    @qps_retry(qps=7)
    def isochrone(self, locations, costing, ranges):
        request_params = self._parse_request_params(locations, costing,
                                                    ranges)
        try:
            # TODO Extract HTTP client wrapper
            session = requests.Session()
            session.mount(self._url, HTTPAdapter(max_retries=self._max_retries))
            response = session.get(self._url, params=request_params,
                                    timeout=(self._connect_timeout,
                                            self._read_timeout))

            if response.status_code is requests.codes.ok:
                return self._parse_response(response)
            elif response.status_code == requests.codes.bad_request:
                return []
            else:
                self._logger.error('Error trying to get isochrones from mapzen',
                                data={"response_status": response.status_code,
                                      "response_reason": response.reason,
                                      "response_content": response.text,
                                      "reponse_url": response.url,
                                      "response_headers": response.headers,
                                      "locations": locations,
                                      "costing": costing})
                raise ServiceException('Error trying to get isochrones from mapzen',
                                       response)
        except requests.Timeout as te:
            # In case of timeout we want to stop the job because the server
            # could be down
            self._logger.error('Timeout connecting to Mapzen isochrones server', exception=te)
            raise ServiceException('Error trying to calculate isochrones using mapzen',
                                    None)
        except requests.ConnectionError as e:
            # Don't raise the exception to continue with the geocoding job
            self._logger.error('Error connecting to Mapzen isochrones server',
                               exception=e)
            return []

    def _parse_request_params(self, locations, costing, ranges):
        if costing in self.ACCEPTED_MODES:
            mode_source = self.ACCEPTED_MODES[costing]
        else:
            raise WrongParams("{0} is not an accepted mode".format(costing))

        contours = []
        for r in ranges:
            # range is in seconds but mapzen uses minutes
            range_minutes = r / 60
            contours.append({"time": range_minutes, "color": 'tbd'})
        request_params = {
            'json': json.dumps({'locations': [locations],
                                'costing': mode_source,
                                'contours': contours,
                                'generalize': 50,
                                'denoise': .3}),
            'api_key': self._app_key
        }

        return request_params

    def _parse_response(self, response):
        try:
            json_response = response.json()
            isochrones = []
            for feature in json_response['features']:
                # Coordinates could have more than one isochrone. For the
                # moment we're getting the first polygon only
                coordinates = feature['geometry']['coordinates']
                duration = feature['properties']['contour']
                mapzen_response = MapzenIsochronesResponse(coordinates,
                                                           duration)
                isochrones.append(mapzen_response)
            return isochrones
        except IndexError:
            return []
        except KeyError:
            self._logger.error('Non existing key for mapzen isochrones response',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers})
            raise MalformedResult()
        except ValueError:
            # JSON decode error
            self._logger.error('JSON decode error for Mapzen isochrones',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers})
            return []


class MapzenIsochronesResponse:

    def __init__(self, coordinates, duration):
        self._coordinates = coordinates
        self._duration = duration

    @property
    def coordinates(self):
        return self._coordinates

    @property
    def duration(self):
        return self._duration

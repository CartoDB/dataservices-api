import requests
import json
import re

from exceptions import WrongParams, MalformedResult
from qps import qps_retry


class MapzenIsochrones:
    'A Mapzen Isochrones wrapper for python'

    BASE_URL = 'https://matrix.mapzen.com/isochrone'

    ACCEPTED_MODES = {
        "walk": "pedestrian",
        "car": "car"
    }

    def __init__(self, app_key, logger, base_url=BASE_URL):
        self._app_key = app_key
        self._url = base_url
        self._logger = logger

    @qps_retry
    def isochrone(self, locations, costing, ranges):
        request_params = self._parse_request_params(locations, costing,
                                                    ranges)
        response = requests.get(self._url, params=request_params)

        if not requests.codes.ok:
            self._logger.error('Error trying to get isochrones from mapzen',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers,
                                     "locations": locations,
                                     "costing": costing})
            raise Exception('Error trying to get isochrones from mapzen')

        return self._parse_response(response)

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
                                'contours': contours}),
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

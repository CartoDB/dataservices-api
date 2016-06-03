import requests
import json
import re

from math import cos, sin, tan, sqrt, pi, radians, degrees, asin, atan2
from exceptions import WrongParams, MalformedResult
from qps import qps_retry
from cartodb_services.tools import Coordinate, PolyLine


class MapzenIsolines:

    'A Mapzen Isochrones feature using the mapzen distance matrix'

    MATRIX_API_URL = 'https://matrix.mapzen.com/one_to_many'

    ACCEPTED_MODES = {
        "walk": "pedestrian",
        "car": "auto",
    }

    ACCEPTED_TYPES = ['distance', 'time']

    AUTO_SHORTEST = 'auto_shortest'

    OPTIONAL_PARAMS = [
        'mode_type',
    ]

    METRICS_UNITS = 'kilometers'
    IMPERIAL_UNITS = 'miles'

    EARTH_RADIUS_METERS = 6371000
    EARTH_RADIUS_MILES = 3959

    DISTANCE_MULTIPLIER = [0.8, 0.9, 1, 1.10, 1.20] # From 80% to 120% of range
    METERS_PER_SECOND = {
        "walk": 1.38889, #Based on 5Km/h
        "car": 22.3 #Based on 80Km/h
    }
    UNIT_MULTIPLIER = {
        "kilometers": 1,
        "miles": 0.3048
    }

    def __init__(self, app_key, base_url=MATRIX_API_URL):
        self._app_key = app_key
        self._url = base_url

    def calculate_isochrone(self, origin, mode, mode_range=[], units=METRICS_UNITS):
        return self._calculate_isolines(origin, mode, 'time', mode_range, units)

    def calculate_isodistance(self, origin, mode, mode_range=[], units=METRICS_UNITS):
        return self._calculate_isolines(origin, mode, 'distance', mode_range, units)

    def _calculate_isolines(self, origin, mode, mode_type, mode_range=[], units=METRICS_UNITS):
        for r in mode_range:
            radius = self._calculate_radius(r, mode, mode_type, units)
            destination_points = self._calculate_destination_points(origin, radius)
            destination_matrix = self._calculate_destination_matrix(origin, destination_points, mode, units)

    def _calculate_radius(self, init_radius, mode, mode_type, units):
        if mode_type is 'time':
            radius_meters = init_radius * self.METERS_PER_SECOND[mode] * self.UNIT_MULTIPLIER[units]
        else:
            radius_meters = init_radius

        return [init_radius*multiplier for multiplier in self.DISTANCE_MULTIPLIER]

    def _calculate_destination_points(self, origin, radius):
        destinations = []
        angles = [i*36 for i in range(10)]
        for angle in angles:
            d = [self._calculate_destination_point(origin, r, angle) for r in radius]
            destinations.extend(d)
        return destinations

    def _calculate_destination_point(self, origin, radius, angle):
        bearing = radians(angle)
        origin_lat_radians = radians(origin.latitude)
        origin_long_radians = radians(origin.longitude)
        dest_lat_radians = asin(sin(origin_lat_radians) * cos(radius / self.EARTH_RADIUS_METERS) + cos(origin_lat_radians) * sin(radius / self.EARTH_RADIUS_METERS) * cos(bearing))
        dest_lng_radians = origin_long_radians + atan2(sin(bearing) * sin(radius / self.EARTH_RADIUS_METERS) * cos(origin_lat_radians), cos(radius / self.EARTH_RADIUS_METERS) - sin(origin_lat_radians) * sin(dest_lat_radians))

        return Coordinate(degrees(dest_lng_radians), degrees(dest_lat_radians))

    def _calculate_destination_matrix(self, origin, destination_points, mode, units):
        json_request_params = self.__parse_json_parameters(destination_points, mode, units)
        request_params = self.__parse_request_parameters(json_request_params)
        response = requests.get(self._url, params=request_params)
        import ipdb; ipdb.set_trace()  # breakpoint 2b65ce71 //
        if response.status_code == requests.codes.ok:
            return self.__parse_routing_response(response.text)
        elif response.status_code == requests.codes.bad_request:
            return MapzenIsochronesResponse(None, None, None)
        else:
            response.raise_for_status()

    def __parse_request_parameters(self, json_request):
        request_options = {"json": json_request}
        request_options.update({'api_key': self._app_key})

        return request_options

    def __parse_json_parameters(self, destination_points, mode, units):
        import ipdb; ipdb.set_trace()  # breakpoint 2b65ce71 //
        json_options = {"locations": self._parse_destination_points(destination_points)}
        json_options.update({'costing': self.ACCEPTED_MODES[mode]})
        #json_options.update({"directions_options": {'units': units,
        #                     'narrative': False}})

        return json.dumps(json_options)

    def _parse_destination_points(self, destination_points):
        destinations = []
        for dest in destination_points:
            destinations.append({"lat": dest.latitude, "lon": dest.longitude})

        return destinations


    def __parse_matrix_response(self, response):
        try:
            parsed_json_response = json.loads(response)
        except IndexError:
            return []
        except KeyError:
            raise MalformedResult()

    def __parse_mode_param(self, mode, options):
        if mode in self.ACCEPTED_MODES:
            mode_source = self.ACCEPTED_MODES[mode]
        else:
            raise WrongParams("{0} is not an accepted mode type".format(mode))

        if mode == self.ACCEPTED_MODES['car'] and 'mode_type' in options and \
                options['mode_type'] == 'shortest':
            mode = self.AUTO_SHORTEST

        return mode


class MapzenIsochronesResponse:

    def __init__(self, shape, length, duration):
        self._shape = shape
        self._length = length
        self._duration = duration

    @property
    def shape(self):
        return self._shape

    @property
    def length(self):
        return self._length

    @property
    def duration(self):
        return self._duration

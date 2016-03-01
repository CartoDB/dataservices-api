import requests
import json
import re
from polyline.codec import PolylineCodec

from exceptions import WrongParams
from cartodb_services.tools import Coordinate


class MapzenRouting:
    'A Mapzen Routing wrapper for python'

    PRODUCTION_ROUTING_BASE_URL = 'https://valhalla.mapzen.com/route'

    ACCEPTED_MODES = {
        "walk": "pedestrian",
        "car": "auto",
        "public_transport": "bus",
        "bicycle": "bicycle"
    }

    AUTO_SHORTEST = 'auto_shortest'

    OPTIONAL_PARAMS = [
        'mode_type',
    ]

    METRICS_UNITS = 'kilometers'
    IMPERIAL_UNITS = 'miles'

    def __init__(self, app_key, base_url=PRODUCTION_ROUTING_BASE_URL):
        self._app_key = app_key
        self._url = base_url

    def calculate_route_point_to_point(self, origin, destination, mode,
                                       options=[], units=METRICS_UNITS):
        parsed_options = self.__parse_options(options)
        mode_param = self.__parse_mode_param(mode, parsed_options)
        directions = self.__parse_directions(origin, destination)
        json_request_params = self.__parse_json_parameters(directions,
                                                           mode_param,
                                                           units)
        request_params = self.__parse_request_parameters(json_request_params)
        response = requests.get(self._url, params=request_params)
        if response.status_code == requests.codes.ok:
            return self.__parse_routing_response(response.text)
        else:
            response.raise_for_status()

    def __parse_options(self, options):
        return dict(option.split('=') for option in options)

    def __parse_request_parameters(self, json_request):
        request_options = {"json": json_request}
        request_options.update({'api_key': self._app_key})

        return request_options

    def __parse_json_parameters(self, directions, mode, units):
        json_options = directions
        json_options.update({'costing': self.ACCEPTED_MODES[mode]})
        json_options.update({"directions_options": {'units': units,
                             'narrative': False}})

        return json.dumps(json_options)

    def __parse_directions(self, origin, destination):
        return {"locations": [
                {"lon": origin.longitude, "lat": origin.latitude},
                {"lon": destination.longitude, "lat": destination.latitude}
                ]}

    def __parse_routing_response(self, response):
        try:
            parsed_json_response = json.loads(response)
            legs = parsed_json_response['trip']['legs'][0]
            shape = PolylineCodec().decode(legs['shape'])
            length = legs['summary']['length']
            duration = legs['summary']['time']
            routing_response = MapzenRoutingResponse(shape, length, duration)

            return routing_response
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


class MapzenRoutingResponse:

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

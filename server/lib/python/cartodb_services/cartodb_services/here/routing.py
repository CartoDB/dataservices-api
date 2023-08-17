import requests
import json
import flexpolyline as fp

from cartodb_services.here.exceptions import WrongParams
from requests.adapters import HTTPAdapter
from cartodb_services.metrics import Traceable


class HereMapsRoutingIsoline(Traceable):
    'A Here Maps Routing v7 wrapper for python'

    PRODUCTION_ROUTING_BASE_URL = 'https://isoline.route.api.here.com'
    STAGING_ROUTING_BASE_URL = 'https://isoline.route.cit.api.here.com'
    ISOLINE_PATH = '/routing/7.2/calculateisoline.json'
    API_VERSION = 7
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1

    ACCEPTED_MODES = {
        "walk": "pedestrian",
        "car": "car"
    }

    OPTIONAL_PARAMS = [
        'departure',
        'arrival',
        'singlecomponent',
        'resolution',
        'maxpoints',
        'quality'
    ]

    def __init__(self, app_id, app_code, logger, service_params=None):
        service_params = service_params or {}
        self._app_id = app_id
        self._app_code = app_code
        self._logger = logger
        base_url = service_params.get('base_url', self.PRODUCTION_ROUTING_BASE_URL)
        isoline_path = service_params.get('isoline_path', self.ISOLINE_PATH)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)
        self._url = "{0}{1}".format(base_url, isoline_path)

    def get_api_version(self):
        return self.API_VERSION

    def calculate_isodistance(self, source, mode, data_range, options=[]):
        return self.__calculate_isolines(source, mode, data_range, 'distance',
                                         options)

    def calculate_isochrone(self, source, mode, data_range, options=[]):
        return self.__calculate_isolines(source, mode, data_range, 'time',
                                         options)

    def __calculate_isolines(self, source, mode, data_range, range_type,
                             options=None):
        options = options or []
        parsed_options = self.__parse_options(options)
        source_param = self.__parse_source_param(source, parsed_options)
        mode_param = self.__parse_mode_param(mode, parsed_options)
        request_params = self.__parse_request_parameters(source_param,
                                                         mode_param,
                                                         data_range,
                                                         range_type,
                                                         parsed_options)
        # TODO Extract HTTP client wrapper
        session = requests.Session()
        session.mount(self._url, HTTPAdapter(max_retries=self.max_retries))
        response = requests.get(self._url, params=request_params,
                                timeout=(self.connect_timeout, self.read_timeout))
        self.add_response_data(response, self._logger)
        if response.status_code == requests.codes.ok:
            return self.__parse_isolines_response(response.text)
        elif response.status_code == requests.codes.bad_request:
            return []
        else:
            self._logger.error('Error trying to calculate HERE isolines',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers,
                                     "source": source, "mode": mode,
                                     "data_range": data_range,
                                     "range_type": range_type,
                                     "options": options})
            raise Exception('Error trying to calculate HERE isolines')

    def __parse_options(self, options):
        return dict(option.split('=') for option in options)

    def __parse_request_parameters(self, source, mode, data_range, range_type,
                                   options):
        filtered_options = {k: v for k, v in options.iteritems()
                            if k.lower() in self.OPTIONAL_PARAMS}
        filtered_options.update(source)
        filtered_options.update(mode)
        filtered_options.update({'range': ",".join(map(str, data_range))})
        filtered_options.update({'rangetype': range_type})
        filtered_options.update({'app_id': self._app_id})
        filtered_options.update({'app_code': self._app_code})

        return filtered_options

    def __parse_isolines_response(self, response):
        parsed_response = json.loads(response)
        isolines_response = parsed_response['response']['isoline']
        isolines = []
        for isoline in isolines_response:
            if not isoline['component']:
                geom_value = []
            else:
                geom_value = isoline['component'][0]['shape']
            isolines.append({'range': isoline['range'],
                             'geom': geom_value})

        return isolines

    def __parse_source_param(self, source, options):
        key = 'start'
        if 'is_destination' in options and options['is_destination'].lower() == 'true':
            key = 'destination'

        return {key: source}

    def __parse_mode_param(self, mode, options):
        if mode in self.ACCEPTED_MODES:
            mode_source = self.ACCEPTED_MODES[mode]
        else:
            raise WrongParams("{0} is not an accepted mode type".format(mode))

        if 'mode_type' in options:
            mode_type = options['mode_type']
        else:
            mode_type = 'shortest'

        if 'mode_traffic' in options:
            mode_traffic = "traffic:{0}".format(options['mode_traffic'])
        else:
            mode_traffic = None

        if 'mode_feature' in options and 'mode_feature_weight' in options:
            mode_feature = "{0}:{1}".format(options['mode_feature'],
                                     options['mode_feature_weight'])
        else:
            mode_feature = None

        mode_param = "{0};{1}".format(mode_type, mode_source)
        if mode_traffic:
            mode_param = "{0};{1}".format(mode_param, mode_traffic)

        if mode_feature:
            mode_param = "{0};{1}".format(mode_param, mode_feature)

        return {'mode': mode_param}

class HereMapsRoutingIsolineV8(Traceable):
    'A Here Maps Routing v8 wrapper for python'

    PRODUCTION_ROUTING_BASE_URL = 'https://isoline.router.hereapi.com/v8/isolines'
    API_VERSION = 8
    READ_TIMEOUT = 60
    CONNECT_TIMEOUT = 10
    MAX_RETRIES = 1
    QUALITY_PARAM_V7 = 'quality'
    DEFAULT_OPTIMIZEFOR = 'quality'
    DEFAULT_ROUTINGMODE = 'short'
    HERE_WALK_MODE = "pedestrian"
    HERE_CAR_MODE = "car"

    ACCEPTED_MODES = {
        "walk": HERE_WALK_MODE,
        "car": HERE_CAR_MODE
    }

    OPTIONAL_PARAMS = [
        'departure',
        'arrival',
        'maxpoints',
        'quality',
        'mode_feature'
    ]

    def __init__(self, apikey, logger, service_params=None):
        service_params = service_params or {}
        self._apikey = apikey
        self._logger = logger
        self._url = service_params.get('base_url', self.PRODUCTION_ROUTING_BASE_URL)
        self.connect_timeout = service_params.get('connect_timeout', self.CONNECT_TIMEOUT)
        self.read_timeout = service_params.get('read_timeout', self.READ_TIMEOUT)
        self.max_retries = service_params.get('max_retries', self.MAX_RETRIES)

    def get_api_version(self):
        return self.API_VERSION

    def calculate_isodistance(self, source, mode, data_range, options=None):
        options = options or []
        return self.__calculate_isolines(source, mode, data_range, 'distance',
                                         options)

    def calculate_isochrone(self, source, mode, data_range, options=None):
        options = options or []
        return self.__calculate_isolines(source, mode, data_range, 'time',
                                         options)

    def __calculate_isolines(self, source, mode, data_range, range_type,
                             options=None):
        options = options or []
        parsed_options = self.__parse_options(options)
        source_param = self.__parse_source_param(source, parsed_options)
        mode_params = self.__get_mode_params(mode, parsed_options)
        request_params = self.__parse_request_parameters(source_param,
                                                         mode_params,
                                                         data_range,
                                                         range_type,
                                                         parsed_options)
        # TODO Extract HTTP client wrapper
        session = requests.Session()
        session.mount(self._url, HTTPAdapter(max_retries=self.max_retries))
        response = requests.get(self._url, params=request_params,
                                timeout=(self.connect_timeout, self.read_timeout))
        self.add_response_data(response, self._logger)
        if response.status_code == requests.codes.ok:
            return self.__parse_isolines_response(response.text)
        elif response.status_code == requests.codes.bad_request:
            return []
        else:
            self._logger.error('Error trying to calculate HERE isolines',
                               data={"response_status": response.status_code,
                                     "response_reason": response.reason,
                                     "response_content": response.text,
                                     "reponse_url": response.url,
                                     "response_headers": response.headers,
                                     "source": source, "mode": mode,
                                     "data_range": data_range,
                                     "range_type": range_type,
                                     "options": options})
            raise Exception('Error trying to calculate HERE isolines')

    def __parse_options(self, options):
        return dict(option.split('=') for option in options)

    def __get_v8_param(self, param, reverse=False):
        mapping = {
            'range': 'range[values]',
            'rangetype': 'range[type]',
            'mode': {
                'type': 'routingmode',
                'transportmodes': 'transportmode',
                'trafficmode': None,
                'feature': 'avoid[feature]'
                },
            'quality': 'optimizefor',
            'maxpoints': 'shape[maxpoints]',
            'start': 'origin',
            'destination': 'destination',
            'departure': 'departuretime',
            'arrival': 'arrivaltime',
            'mode_feature': 'avoid[features]'
        }

        if reverse is True:
            mapping = {v:k for k,v in mapping.items()}

        return mapping.get(param)

    def __get_v8_optimizefor_value(self, quality, reverse=False):
        mapping = {
            1: 'quality',
            2: 'balanced',
            3: 'performance'
        }

        if reverse is True:
            mapping = {v:k for k,v in mapping.items()}

        return mapping.get(quality, self.DEFAULT_OPTIMIZEFOR)

    def __get_v8_routingmode_value(self, mode_type, reverse=False):
        mapping = {
            'fastest': 'fast',
            'shortest': 'short'
        }

        if reverse is True:
            mapping = {v:k for k,v in mapping.items()}

        return mapping.get(mode_type, self.DEFAULT_ROUTINGMODE)

    def __parse_request_parameters(self, source, mode, data_range, range_type,
                                   options):
        quality = self.QUALITY_PARAM_V7

        if quality in options.keys():
            options[quality] = self.__get_v8_optimizefor_value(options[quality])

        filtered_options = {self.__get_v8_param(k): v for k, v in options.iteritems()
                            if k.lower() in self.OPTIONAL_PARAMS}

        filtered_options.update(source)
        filtered_options.update(mode)
        filtered_options.update({'range[values]': ",".join(map(str, data_range))})
        filtered_options.update({'range[type]': range_type})
        filtered_options.update({'apikey': self._apikey})

        return filtered_options

    def __parse_isolines_response(self, response):
        parsed_response = json.loads(response)
        isolines_response = parsed_response['isolines']
        isolines = []
        for isoline in isolines_response:
            if not isoline['polygons']:
                geom_value = []
            else:
                geom_value = fp.decode(isoline['polygons'][0]['outer'])
            isolines.append({'range': isoline['range']['value'],
                             'geom': geom_value})

        return isolines

    def __parse_source_param(self, source, options):
        key = 'origin'
        if 'is_destination' in options and options['is_destination'].lower() == 'true':
            key = 'destination'

        return {key: source}

    def __get_mode_params(self, mode, options):
        mode_params = {}
        if mode in self.ACCEPTED_MODES:
            mode_source = self.ACCEPTED_MODES[mode]
            mode_params.update({'transportmode': mode_source})
        else:
            raise WrongParams("{0} is not an accepted mode type".format(mode))

        if 'mode_type' in options:
            mode_type = self.__get_v8_routingmode_value(options['mode_type'])
        else:
            mode_type = self.DEFAULT_ROUTINGMODE

        # Do not set routingmode if transportmode value is equivalent to 'walk' mode
        if mode_source != self.HERE_WALK_MODE:
            mode_params.update({'routingmode': mode_type})

        if not ('mode_traffic' in options and options['mode_traffic'] == 'enabled'):
            mode_params.update({'departuretime': 'any'})

        return mode_params

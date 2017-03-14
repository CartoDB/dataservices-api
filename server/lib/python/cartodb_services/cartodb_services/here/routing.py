import requests
import json

from exceptions import WrongParams
from requests.adapters import HTTPAdapter
from cartodb_services.metrics import Traceable


class HereMapsRoutingIsoline(Traceable):
    'A Here Maps Routing wrapper for python'

    PRODUCTION_ROUTING_BASE_URL = 'https://isoline.route.api.here.com'
    STAGING_ROUTING_BASE_URL = 'https://isoline.route.cit.api.here.com'
    ISOLINE_PATH = '/routing/7.2/calculateisoline.json'
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

    def calculate_isodistance(self, source, mode, data_range, options=[]):
        return self.__calculate_isolines(source, mode, data_range, 'distance',
                                         options)

    def calculate_isochrone(self, source, mode, data_range, options=[]):
        return self.__calculate_isolines(source, mode, data_range, 'time',
                                         options)

    def __calculate_isolines(self, source, mode, data_range, range_type,
                             options=[]):
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
        if 'is_destination' in options and options['is_destination']:
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

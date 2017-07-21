import abc
import json
import re
import time
import uuid
import plpy
from datetime import datetime
from contextlib import contextmanager
from urlparse import urlparse


@contextmanager
def metrics(function, service_config, logger=None):
    try:
        start_time = time.time()
        yield
    finally:
        end_time = time.time()
        MetricsDataGatherer.add('uuid', str(uuid.uuid1()))
        MetricsDataGatherer.add('function_name', function)
        MetricsDataGatherer.add('function_execution_time', (end_time - start_time))
        metrics_logger = MetricsServiceLoggerFactory.build(service_config,
                                                           logger)
        if metrics_logger:
            data = MetricsDataGatherer.get()
            metrics_logger.log(data)
        MetricsDataGatherer.clean()


class Traceable:
    """
    Module to add metrics traceability, for example to get response object
    in order to add to the metrics dump
    """
    def add_response_data(self, response, logger=None):
        try:
            response_data = {}
            response_data['type'] = "request"
            response_data['date'] = datetime.now().isoformat()
            response_data['elapsed_time'] = response.elapsed.total_seconds()
            response_data['code'] = response.status_code
            response_data['message'] = response.reason
            response_data['url'] = self._parse_response_url(response.url)
            stored_data = MetricsDataGatherer.get_element('response')
            if stored_data:
                stored_data.append(response_data)
            else:
                MetricsDataGatherer.add('response', [response_data])
        except BaseException as e:
            # We don't want to stop the job for some error processing response
            if logger:
                logger.error("Error trying to process response metricd data",
                             exception=e)

    def _parse_response_url(self, url):
        u = urlparse(url)
        return "{0}://{1}{2}".format(u.scheme, u.netloc, u.path)


class MetricsDataGatherer:
    """
    Metrics gatherer used as a singleton. The intend is to use it as a global
    storage for the metrics along the function request.
    """

    class __MetricsDataGatherer:
        def __init__(self):
            self.data = {}

        def add(self, key, value):
            self.data[key] = value

        def get(self):
            return self.data

        def get_element(self, key):
            return self.data.get(key, None)

        def clean(self):
            self.data = {}


    #  We use pgbouncer so we need to have multiples instances per request id
    __instance = {}

    @classmethod
    def add(self, key, value):
        MetricsDataGatherer.instance().add(key, value)

    @classmethod
    def get(self):
        return MetricsDataGatherer.instance().get()

    @classmethod
    def get_element(self, key):
        return MetricsDataGatherer.instance().get_element(key)

    @classmethod
    def clean(self):
        MetricsDataGatherer.instance().clean()

    @classmethod
    def instance(self):
        txid = MetricsDataGatherer._get_txid()
        if txid not in MetricsDataGatherer.__instance:
            MetricsDataGatherer.__instance[txid] = MetricsDataGatherer.__MetricsDataGatherer()

        return MetricsDataGatherer.__instance[txid]

    @classmethod
    def _get_txid(self):
        result = plpy.execute('select txid_current() as txid')
        return result[0]['txid']


class MetricsServiceLoggerFactory:

    @classmethod
    def build(self, service_config, logger=None):
        if re.search('^geocoder_*', service_config.service_type):
            return MetricsGeocoderLogger(service_config, logger)
        elif re.search('^routing_*', service_config.service_type):
            return MetricsGenericLogger(service_config, logger)
        elif re.search('_isolines$', service_config.service_type):
            return MetricsIsolinesLogger(service_config, logger)
        elif re.search('^obs_*', service_config.service_type):
            return MetricsGenericLogger(service_config, logger)
        else:
            return None


class MetricsLogger(object):
    __metaclass__ = abc.ABCMeta

    def __init__(self, service_config, logger):
        self._service_config = service_config
        self._logger = logger

    def dump_to_file(self, data):
        try:
            log_path = self.service_config.metrics_log_path
            response_data = data.pop('response', [])
            uuid = data.get('uuid')
            if log_path:
                with open(log_path, 'a') as logfile:
                    self._dump_response_to_file(uuid, response_data, logfile)
                    json.dump(data, logfile)
                    logfile.write('\n')
        except BaseException as e:
            self._logger.error("Error dumping metrics to file {0}".format(log_path),
                         exception=e)

    def collect_data(self, data):
        return {
            "uuid": data.get('uuid', uuid.uuid1()),
            "type": 'function',
            "function_name": data.get('function_name', None),
            "function_execution_time": data.get('function_execution_time',
                                                None),
            "service": self._service_config.service_type,
            "processable_rows": 1,
            "success": data.get('success', False),
            "successful_rows": data.get('successful_rows', 0),
            "failed_rows": data.get('failed_rows', 0),
            "empty_rows": data.get('empty_rows', 0),
            "created_at": datetime.now().isoformat(),
            "provider": self._service_config.provider,
            "username": self._service_config.username,
            "organization": self._service_config.organization,
            "response": data.get('response', [])
        }

    def _dump_response_to_file(self, uuid, response_data, log_file):
        for r in response_data:
            r['uuid'] = uuid
            json.dump(r, log_file)
            log_file.write('\n')

    @property
    def service_config(self):
        return self._service_config

    @abc.abstractproperty
    def log(self, data):
        raise NotImplementedError('log method must be defined')


class MetricsGeocoderLogger(MetricsLogger):

    def __init__(self, service_config, logger):
        super(MetricsGeocoderLogger, self).__init__(service_config, logger)

    def log(self, data):
        dump_data = self.collect_data(data)
        self.dump_to_file(dump_data)

    def collect_data(self, data):
        dump_data = super(MetricsGeocoderLogger, self).collect_data(data)
        if data.get('success', False):
            cost = self.service_config.cost_per_hit
        else:
            cost = 0

        if self.service_config.is_high_resolution:
            kind = 'high-resolution'
        else:
            kind = 'internal'

        dump_data.update({
            "batched": False,
            "cache_hits": 0,  # Always 0 because no cache involved
            # https://github.com/CartoDB/cartodb/blob/master/app/models/geocoding.rb#L208-L211
            "cost": cost,
            "geocoder_type": self.service_config.service_type,
            "kind": kind,
            "processed_rows": data.get('successful_rows', 0),
            "real_rows": data.get('successful_rows', 0),
        })

        return dump_data


class MetricsGenericLogger(MetricsLogger):

    def __init__(self, service_config, logger):
        super(MetricsGenericLogger, self).__init__(service_config, logger)

    def log(self, data):
        dump_data = self.collect_data(data)
        self.dump_to_file(dump_data)

    def collect_data(self, data):
        return super(MetricsGenericLogger, self).collect_data(data)


class MetricsIsolinesLogger(MetricsLogger):

    def __init__(self, service_config, logger):
        super(MetricsIsolinesLogger, self).__init__(service_config, logger)

    def log(self, data):
        dump_data = self.collect_data(data)
        self.dump_to_file(dump_data)

    def collect_data(self, data):
        dump_data = super(MetricsIsolinesLogger, self).collect_data(data)
        dump_data.update({
            "isolines_generated": data.get('isolines_generated', 0)
        })
        return dump_data

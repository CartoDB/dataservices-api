
import abc
import json
import re


class LoggerFactory:

    @classmethod
    def build(self, service_config):
        if re.match('geocoder_*', service_config.service_type):
            return GeocoderLogger(service_config)
        else:
            return None


class Logger(object):
    __metaclass__ = abc.ABCMeta

    def __init__(self, file_path):
        self._file_path = file_path

    def dump_to_file(self, data):
        with open(self._file_path, 'a') as logfile:
            json.dump(data, logfile)

    @abc.abstractproperty
    def log(self, **data):
        raise NotImplementedError('log method must be defined')


class GeocoderLogger(Logger):

    def __init__(self, service_config):
        super(GeocoderLogger, self).__init__(service_config.log_path)
        self._service_config = service_config

    def log(self, **data):
        dump_data = self._dump_data(**data)
        self.dump_to_file(dump_data)

    def _dump_data(self, **data):
        if data['success']:
            cost = self._service_config.cost_per_hit
            failed_rows = 0
            successful_rows = 1
        else:
            cost = 0
            failed_rows = 1
            successful_rows = 0

        if self._service_config.is_high_resolution:
            kind = 'high-resolution'
        else:
            kind = 'internal'

        return {
            "batched": False,
            "cache_hits": 0,  # Always 0 because no cache involved
            # https://github.com/CartoDB/cartodb/blob/master/app/models/geocoding.rb#L208-L211
            "cost": cost,
            "created_at": datetime.now().isoformat(),
            "failed_rows": failed_rows,
            "geocoder_type": self._service_config.service_type,
            "kind": kind,
            "processable_rows": 1,
            "processed_rows": successful_rows,
            "real_rows": successful_rows,
            "success": data['success'],
            "successful_rows": successful_rows,
            "used_credits": 0,
            "username": self._service_config.username,
            "organization": self._service_config.organization
        }

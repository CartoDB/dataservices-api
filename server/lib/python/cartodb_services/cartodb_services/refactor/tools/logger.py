from cartodb_services.refactor.config.exceptions import ConfigException

class LoggerConfig(object):

    """This class is a value object needed to setup a Logger"""

    def __init__(self, server_environment, rollbar_api_key, log_file_path, min_log_level):
        self._server_environment = server_environment
        self._rollbar_api_key = rollbar_api_key
        self._log_file_path = log_file_path
        self._min_log_level = min_log_level

    @property
    def environment(self):
        return self._server_environment

    @property
    def rollbar_api_key(self):
        return self._rollbar_api_key

    @property
    def log_file_path(self):
        return self._log_file_path

    @property
    def min_log_level(self):
        return self._min_log_level

# TODO this needs tests
# TODO FTM this is just config, maybe move around
class LoggerConfigBuilder(object):

    def __init__(self, server_config_storage):
        self._server_config_storage = server_config_storage

    def get(self):
        server_environment = self._get_server_environment()

        logger_conf = self._server_config_storage.get('logger_conf')
        if not logger_conf:
            raise ConfigException('Logger configuration missing')
        
        rollbar_api_key = self._get_value_or_none(logger_conf, 'rollbar_api_key')
        log_file_path = self._get_value_or_none(logger_conf, 'log_file_path')
        min_log_level = self._get_value_or_none(logger_conf, 'min_log_level') or 'warning'

        logger_config = LoggerConfig(server_environment, rollbar_api_key, log_file_path, min_log_level)
        return logger_config

    def _get_server_environment(self):
        server_config = self._server_config_storage.get('server_conf')
        if not server_config:
            environment = 'development'
        else:
            if 'environment' in server_config:
                environment = server_config['environment']
            else:
                environment = 'development'

        return environment

    def _get_value_or_none(self, logger_conf, key):
        value = None
        if key in logger_conf:
            value = logger_conf[key]
        return value

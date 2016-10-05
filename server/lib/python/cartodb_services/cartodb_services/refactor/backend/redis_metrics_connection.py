from cartodb_services.refactor.tools.redis_mock import RedisConnectionMock
from cartodb_services.refactor.storage.redis_connection_config import RedisMetricsConnectionConfigBuilder
from cartodb_services.refactor.storage.redis_connection import RedisConnectionBuilder

class RedisMetricsConnectionFactory(object):
    def __init__(self, environment, server_config_storage):
        self._environment = environment
        self._server_config_storage = server_config_storage

    def get(self):
        if self._environment.is_onpremise:
           redis_metrics_connection = RedisConnectionMock()
        else:
          redis_metrics_connection_config = RedisMetricsConnectionConfigBuilder(self._server_config_storage).get()
          redis_metrics_connection = RedisConnectionBuilder(redis_metrics_connection_config).get()
        return redis_metrics_connection


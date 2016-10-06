from cartodb_services.refactor.config.exceptions import ConfigException
from abc import ABCMeta, abstractmethod


class RedisConnectionConfig(object):
    """
    This represents a value object to contain configuration needed to set up
    a connection to a redis server.
    """

    def __init__(self, host, port, timeout, db, sentinel_id):
        self._host = host
        self._port = port
        self._timeout = timeout
        self._db = db
        self._sentinel_id = sentinel_id

    @property
    def host(self):
        return self._host

    @property
    def port(self):
        return self._port

    @property
    def timeout(self):
        return self._timeout

    @property
    def db(self):
        return self._db

    @property
    def sentinel_id(self):
        return self._sentinel_id


class RedisConnectionConfigBuilder(object):

    __metaclass__ = ABCMeta

    DEFAULT_USER_DB = 5
    DEFAULT_TIMEOUT = 1.5  # seconds

    @abstractmethod
    def __init__(self, server_config_storage, config_key):
        self._server_config_storage = server_config_storage
        self._config_key = config_key

    def get(self):
        conf = self._server_config_storage.get(self._config_key)
        if conf is None:
            raise ConfigException("There is no redis configuration defined")

        host = conf['redis_host']
        port = conf['redis_port']
        timeout = conf.get('timeout', self.DEFAULT_TIMEOUT) or self.DEFAULT_TIMEOUT
        db = conf.get('redis_db', self.DEFAULT_USER_DB) or self.DEFAULT_USER_DB
        sentinel_id = conf.get('sentinel_master_id', None)

        return RedisConnectionConfig(host, port, timeout, db, sentinel_id)


class RedisMetadataConnectionConfigBuilder(RedisConnectionConfigBuilder):

    def __init__(self, server_config_storage):
        super(RedisMetadataConnectionConfigBuilder, self).__init__(
            server_config_storage,
            'redis_metadata_config'
        )


class RedisMetricsConnectionConfigBuilder(RedisConnectionConfigBuilder):

    def __init__(self, server_config_storage):
        super(RedisMetricsConnectionConfigBuilder, self).__init__(
            server_config_storage,
            'redis_metrics_config'
        )

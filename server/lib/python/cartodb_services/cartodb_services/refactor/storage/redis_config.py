from cartodb_services.refactor.config.exceptions import ConfigException
from abc import ABCMeta, abstractmethod

"""
How to use this (just a draft, WIP):

  redis_connection_config = RedisConnectionConfigBuilder(server_config_storage).get()
  connection = RedisConnectionBuilder(redis_connection_config)

  user_config_storage = RedisConfigStorage(connection, user)
  user_config_storage = UserConfigStorageFactory(environment).get()
"""

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
        timeout = conf['timeout'] or self.DEFAULT_TIMEOUT
        db = conf['redis_db'] or self.DEFAULT_USER_DB
        sentinel_id = conf['sentinel_master_id']

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

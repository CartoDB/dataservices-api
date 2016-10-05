from redis.sentinel import Sentinel
from redis import StrictRedis

class RedisConnectionBuilder():

    def __init__(self, connection_config):
        self._config = connection_config

    def get(self):
        if self._config.sentinel_id:
            sentinel = Sentinel([(self._config.host,
                                  self._config.port)],
                                socket_timeout=self._config.timeout)
            return sentinel.master_for(self._config.sentinel_id,
                                       socket_timeout=self._config.timeout,
                                       db=self._config.db,
                                       retry_on_timeout=True)
        else:
            conn = StrictRedis(host=self._config.host, port=self._config.port,
                               db=self._config.db, retry_on_timeout=True,
                               socket_timeout=self._config.timeout)
            return conn

from redis.sentinel import Sentinel
from redis import StrictRedis
import json


class RedisConnection:

    def __init__(self, config):
        self._config = config

    def redis_connection(self):
        return self.__create_redis_connection()

    def __create_redis_connection(self):
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


class RedisDBConfig:

    DEFAULT_USER_DB = 5
    DEFAULT_TIMEOUT = 1.5  # seconds

    def __init__(self, key, db_conn):
        self._db_conn = db_conn
        return self._build(key)

    def _build(self, key):
        conf_query = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(
            key)
        conf = self._db_conn.execute(conf_query)[0]['conf']
        if conf is None:
            raise Exception("There is no redis configuration defined")
        else:
            params = json.loads(conf)
            self._host = params['redis_host']
            self._port = params['redis_port']

            if "timeout" in params:
                self._timeout = params['timeout']
            else:
                self._timeout = self.DEFAULT_TIMEOUT

            if "redis_db" in params:
                self._db = params['redis_db']
            else:
                self._db = self.DEFAULT_USER_DB

            if "sentinel_master_id" in params:
                self._sentinel_id = params["sentinel_master_id"]
            else:
                self._sentinel_id = None

    def __str__(self):
        return "Host: {0}, Port: {1}, Sentinel id: {2}, DB: {3}, " \
               "Timeout: {4}".format(self.host, self.port, self.sentinel_id,
                                     self.db, self.timeout)

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

from redis.sentinel import Sentinel


class RedisConnection:

    REDIS_DEFAULT_USER_DB = 5
    REDIS_DEFAULT_TIMEOUT = 2  #seconds
    REDIS_SENTINEL_DEFAULT_PORT = 26379

    def __init__(self, sentinel_host, sentinel_port, sentinel_master_id,
                 redis_db=REDIS_DEFAULT_USER_DB, **kwargs):
        self.sentinel_host = sentinel_host
        self.sentinel_port = sentinel_port
        self.sentinel_master_id = sentinel_master_id
        self.timeout = kwargs['timeout'] if 'timeout' in kwargs else self.REDIS_DEFAULT_TIMEOUT
        self.redis_db = redis_db

    def redis_connection(self):
        return self.__create_redis_connection()

    def __create_redis_connection(self):
        sentinel = Sentinel([(self.sentinel_host,
                              self.REDIS_SENTINEL_DEFAULT_PORT)],
                            socket_timeout=self.timeout)
        return sentinel.master_for(
            self.sentinel_master_id,
            socket_timeout=self.timeout,
            db=self.redis_db
        )

from redis.sentinel import Sentinel

class RedisHelper:

  REDIS_DEFAULT_USER_DB = 5
  REDIS_TIMEOUT = 2 #seconds

  def __init__(self, sentinel_host, sentinel_port, sentinel_master_id, redis_db=REDIS_DEFAULT_USER_DB, **kwargs):
    self.sentinel_host = sentinel_host
    self.sentinel_port = sentinel_port
    self.sentinel_master_id = sentinel_master_id
    self.timeout = kwargs['timeout'] if 'timeout' in kwargs else REDIS_DEFAULT_TIMEOUT
    self.redis_db = redis_db

  def redis_connection(self):
    return self.__create_redis_connection()

  def __create_redis_connection(self):
    sentinel = Sentinel([(self.sentinel_host, 26379)], socket_timeout=self.timeout)
    return sentinel.master_for(self.sentinel_master_id, socket_timeout=self.timeout, db=self.redis_db)
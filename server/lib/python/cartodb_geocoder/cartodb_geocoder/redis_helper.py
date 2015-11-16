import redis

class RedisHelper:

  REDIS_DEFAULT_USER_DB = 5
  REDIS_DEFAULT_HOST = 'localhost'
  REDIS_DEFAULT_PORT = 6379

  def __init__(self, host, port=REDIS_DEFAULT_PORT, db=REDIS_DEFAULT_USER_DB):
    self.host = host
    self.port = port
    self.db = db

  def redis_connection(self):
    return self.__create_redis_connection()

  def __create_redis_connection(self):
    #TODO Change to use Sentinel
    pool = redis.ConnectionPool(host=self.host, port=self.port, db=self.db)
    return redis.Redis(connection_pool=pool)
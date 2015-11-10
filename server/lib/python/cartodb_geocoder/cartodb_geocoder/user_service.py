import redis
from datetime import date

class UserService:
  """ Class to manage all the user info """

  GEOCODING_QUOTA_KEY = "geocoding_quota"
  REDIS_CONNECTION_KEY = "redis_connection"
  REDIS_CONNECTION_HOST = "redis_host"
  REDIS_CONNECTION_PORT = "redis_port"
  REDIS_CONNECTION_DB = "redis_db"

  REDIS_DEFAULT_USER_DB = 5
  REDIS_DEFAULT_HOST = 'localhost'
  REDIS_DEFAULT_PORT = 6379

  def __init__(self, logger, user_id, **kwargs):
    self.user_id = user_id
    self.logger = logger
    if self.REDIS_CONNECTION_KEY in kwargs:
      self.redis_connection = self.__get_redis_connection(redis_connection=kwargs[self.REDIS_CONNECTION_KEY])
    else:
      if self.REDIS_CONNECTION_HOST not in kwargs:
        raise "You have to provide redis configuration"
      redis_config = self.__build_redis_config(kwargs)
      self.redis_connection = self.__get_redis_connection(redis_config = redis_config)

  def get_user_quota(self):
      # Check for exceptions or redis timeout
      user_quota = self.redis_connection.hget(self.__get_user_redis_key(), self.GEOCODING_QUOTA_KEY)
      return int(user_quota) if user_quota else 0

  def get_current_used_quota(self):
      """ Recover the used quota for the user in the current month """
      # Check for exceptions or redis timeout
      current_used = 0
      for _, value in self.redis_connection.hscan_iter(self.__get_month_redis_key()):
          current_used += int(value)
      return current_used

  def increment_geocoder_use(self, key, amount=1):
      # TODO Manage exceptions or timeout
      self.redis_connection.hincrby(self.__get_month_redis_key(),key,amount)

  def get_redis_connection(self):
      return self.redis_connection

  def __get_redis_connection(self, redis_connection=None, redis_config=None):
      if redis_connection:
          conn = redis_connection
      else:
          conn = self.__create_redis_connection(redis_config)

      return conn

  def __create_redis_connection(self, redis_config):
      self.logger.debug("Connecting to redis...")
      pool = redis.ConnectionPool(host=redis_config['host'], port=redis_config['port'], db=redis_config['db'])
      conn = redis.Redis(connection_pool=pool)
      return conn

  def __build_redis_config(self, config):
      redis_host = config[self.REDIS_CONNECTION_HOST] if self.REDIS_CONNECTION_HOST in config else self.REDIS_DEFAULT_HOST
      redis_port = config[self.REDIS_CONNECTION_PORT] if self.REDIS_CONNECTION_PORT in config else self.REDIS_CONNECTION_PORT
      redis_db = config[self.REDIS_CONNECTION_DB] if self.REDIS_CONNECTION_DB in config else self.REDIS_DEFAULT_USER_DB
      return {'host': redis_host, 'port': redis_port, 'db': redis_db}

  def __get_month_redis_key(self):
      today = date.today()
      return "geocoder:{0}:{1}".format(self.user_id, today.strftime("%Y%m"))

  def __get_user_redis_key(self):
      return "geocoder:{0}".format(self.user_id)
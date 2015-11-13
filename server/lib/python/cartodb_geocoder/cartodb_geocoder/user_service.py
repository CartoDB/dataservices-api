import redis_helper
from datetime import date

class UserService:
  """ Class to manage all the user info """

  GEOCODING_QUOTA_KEY = "geocoding_quota"
  GEOCODING_SOFT_LIMIT_KEY = "soft_geocoder_limit"

  REDIS_CONNECTION_KEY = "redis_connection"
  REDIS_CONNECTION_HOST = "redis_host"
  REDIS_CONNECTION_PORT = "redis_port"
  REDIS_CONNECTION_DB = "redis_db"

  def __init__(self, user_id, redis_connection):
    self.user_id = user_id
    self._redis_connection = redis_connection

  def user_quota(self):
      # Check for exceptions or redis timeout
      user_quota = self._redis_connection.hget(self.__get_user_redis_key(), self.GEOCODING_QUOTA_KEY)
      return int(user_quota) if user_quota and int(user_quota) >= 0 else 0

  def soft_geocoder_limit(self):
    """ Check what kind of limit the user has """
    soft_limit = self._redis_connection.hget(self.__get_user_redis_key(), self.GEOCODING_SOFT_LIMIT_KEY)
    return True if soft_limit == '1' else False

  def used_quota_month(self, year, month):
      """ Recover the used quota for the user in the current month """
      # Check for exceptions or redis timeout
      current_used = 0
      for _, value in self._redis_connection.hscan_iter(self.__get_month_redis_key(year,month)):
          current_used += int(value)
      return current_used

  def increment_geocoder_use(self, year, month, key, amount=1):
      # TODO Manage exceptions or timeout
      self._redis_connection.hincrby(self.__get_month_redis_key(year, month),key,amount)

  @property
  def redis_connection(self):
      return self._redis_connection

  def __get_month_redis_key(self, year, month):
      today = date.today()
      return "geocoder:{0}:{1}{2}".format(self.user_id, year, month)

  def __get_user_redis_key(self):
      return "geocoder:{0}".format(self.user_id)
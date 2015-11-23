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

  def __init__(self, user_config, service_type, redis_connection):
    self.user_config = user_config
    self.service_type = service_type
    self._redis_connection = redis_connection

  def used_quota(self, service_type, year, month, day=None):
      """ Recover the used quota for the user in the current month """
      redis_key_data = self.__get_redis_key(service_type, year, month, day)
      current_use = self._redis_connection.hget(redis_key_data['redis_name'], redis_key_data['redis_key'])
      return int(current_use) if current_use else 0

  def increment_service_use(self, service_type, date=date.today(), amount=1):
      """ Increment the services uses in monthly and daily basis"""
      self.__increment_monthly_uses(date, service_type, amount)
      self.__increment_daily_uses(date, service_type, amount)

  # Private functions

  def __increment_monthly_uses(self, date, service_type, amount):
    redis_key_data = self.__get_redis_key(service_type, date.year, date.month)
    self._redis_connection.hincrby(redis_key_data['redis_name'],redis_key_data['redis_key'],amount)

  def __increment_daily_uses(self, date, service_type, amount):
    redis_key_data = self.__get_redis_key(service_type, date.year, date.month, date.day)
    self._redis_connection.hincrby(redis_key_data['redis_name'],redis_key_data['redis_key'],amount)

  def __get_redis_key(self, service_type, year, month, day=None):
    redis_name = self.__parse_redis_name(service_type,day)
    redis_key = self.__parse_redis_key(year,month,day)

    return {'redis_name': redis_name, 'redis_key': redis_key}

  def __parse_redis_name(self,service_type, day=None):
    prefix = "org" if self.user_config.is_organization else "user"
    dated_key = "used_quota_day" if day else "used_quota_month"
    redis_name = "{0}:{1}:{2}:{3}".format(
      prefix, self.user_config.entity_name, service_type, dated_key
    )
    if self.user_config.is_organization and day:
      redis_name = "{0}:{1}".format(redis_name, self.user_config.user_id)

    return redis_name

  def __parse_redis_key(self,year,month,day=None):
    if day:
      redis_key = "{0}_{1}_{2}".format(year,month,day)
    else:
      redis_key = "{0}_{1}".format(year,month)

    return redis_key

from mockredis import MockRedis
from cartodb_geocoder import user_service
from cartodb_geocoder import config_helper
from datetime import datetime
from unittest import TestCase
from nose.tools import assert_raises


class TestUserService(TestCase):

    NOKIA_GEOCODER = 'nokia'

    def setUp(self):
      self.fake_redis_connection = MockRedis()

    def test_user_used_quota_for_a_month(self):
      us = self.__build_user_service()
      self.__increment_month_geocoder_uses('test_user', '20151111')
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 20

    def test_org_used_quota_for_a_month(self):
      us = self.__build_user_service(organization=True)
      self.__increment_month_geocoder_uses('test_user', '20151111', org=True)
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 20

    def test_user_not_amount_in_used_quota_for_month_should_be_0(self):
      us = self.__build_user_service()
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 0

    def test_org_not_amount_in_used_quota_for_month_should_be_0(self):
      us = self.__build_user_service(organization=True)
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 0

    def test_should_increment_user_used_quota(self):
      us = self.__build_user_service()
      date = datetime.strptime("20151111", "%Y%m%d")
      us.increment_service_use(self.NOKIA_GEOCODER, date=date, amount=1)
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 1
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11, 11) == 1

    def test_should_increment_org_used_quota(self):
      us = self.__build_user_service(organization=True)
      date = datetime.strptime("20151111", "%Y%m%d")
      us.increment_service_use(self.NOKIA_GEOCODER, date=date, amount=1)
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11) == 1
      assert us.used_quota(self.NOKIA_GEOCODER, 2015, 11, 11) == 1

    def test_exception_if_not_redis_config(self):
      assert_raises(Exception, user_service.UserService, 'user_id')

    def __build_user_service(self, organization=False, service='nokia'):
      is_organization = 'true' if organization else 'false'
      user_config_json = '{{"is_organization": {0}, "entity_name": "test_user"}}'.format(is_organization)
      user_config = config_helper.UserConfig(user_config_json, 'user_id')

      return user_service.UserService(user_config, service, redis_connection = self.fake_redis_connection)

    def __increment_month_geocoder_uses(self, entity_name, date_string, service='nokia', amount=20, org=False):
      parent_tag = 'org' if org else 'user'
      date = datetime.strptime(date_string, "%Y%m%d")
      redis_name = "{0}:{1}:{2}:used_quota_month".format(parent_tag, entity_name, service)
      redis_key_month = "{0}_{1}".format(date.year, date.month)
      self.fake_redis_connection.hset(redis_name, redis_key_month, amount)
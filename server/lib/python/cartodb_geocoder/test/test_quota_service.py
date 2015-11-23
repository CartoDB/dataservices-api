from mockredis import MockRedis
from cartodb_geocoder import quota_service
from cartodb_geocoder import config_helper
from unittest import TestCase
from nose.tools import assert_raises
from datetime import datetime


class TestQuotaService(TestCase):

  # single user
  #   user:<username>:<service>:used_quota_month:year_month
  #   user:<username>:<service>:used_quota_day:year_month_day
  # organization user
  #   org:<orgname>:<service>:used_quota_month:year_month
  #   org:<orgname>:<service>:<uuid>:used_quota_day:year_month_day

  def setUp(self):
    self.fake_redis_connection = MockRedis()

  def test_should_return_true_if_user_quota_with_no_use(self):
    qs = self.__build_quota_service()
    assert qs.check_user_quota() == True

  def test_should_return_true_if_org_quota_with_no_use(self):
    qs = self.__build_quota_service(organization=True)
    assert qs.check_user_quota() == True

  def test_should_return_true_if_user_quota_is_not_completely_used(self):
    qs = self.__build_quota_service()
    self.__increment_geocoder_uses('test_user', '20151111')
    assert qs.check_user_quota() == True

  def test_should_return_true_if_org_quota_is_not_completely_used(self):
    qs = self.__build_quota_service(organization=True)
    self.__increment_geocoder_uses('test_user', '20151111', org=True)
    assert qs.check_user_quota() == True

  def test_should_return_false_if_user_quota_is_surpassed(self):
    qs = self.__build_quota_service(quota = 1, soft_limit=False)
    self.__increment_geocoder_uses('test_user', '20151111')
    assert qs.check_user_quota() == False

  def test_should_return_false_if_org_quota_is_surpassed(self):
    qs = self.__build_quota_service(organization=True, quota=1)
    self.__increment_geocoder_uses('test_user', '20151111', org=True)
    assert qs.check_user_quota() == False

  def test_should_return_true_if_user_quota_is_surpassed_but_soft_limit_is_enabled(self):
    qs = self.__build_quota_service(quota=1, soft_limit=True)
    self.__increment_geocoder_uses('test_user', '20151111')
    assert qs.check_user_quota() == True

  def test_should_return_true_if_org_quota_is_surpassed_but_soft_limit_is_enabled(self):
    qs = self.__build_quota_service(organization=True, quota=1, soft_limit=True)
    self.__increment_geocoder_uses('test_user', '20151111', org=True)
    assert qs.check_user_quota() == True

  def test_should_check_user_increment_and_quota_check_correctly(self):
    qs = self.__build_quota_service(quota=2, soft_limit=False)
    qs.increment_geocoder_use()
    assert qs.check_user_quota() == True

  def test_should_check_org_increment_and_quota_check_correctly(self):
    qs = self.__build_quota_service(organization=True, quota=2, soft_limit=False)
    qs.increment_geocoder_use()
    assert qs.check_user_quota() == True

  def __build_quota_service(self, quota=100, service='nokia', organization=False, soft_limit=False):
    is_organization = 'true' if organization else 'false'
    has_soft_limit = 'true' if soft_limit else 'false'
    user_config_json = '{{"is_organization": {0}, "entity_name": "test_user"}}'.format(is_organization)
    geocoder_config_json = """{{"street_geocoder_provider": "{0}","nokia_monthly_quota": {1},
      "nokia_soft_geocoder_limit": {2}}}""".format(service, quota, has_soft_limit)
    user_config = config_helper.UserConfig(user_config_json, 'user_id')
    geocoder_config = config_helper.GeocoderConfig(geocoder_config_json)

    return quota_service.QuotaService(user_config, geocoder_config, redis_connection = self.fake_redis_connection)

  def __increment_geocoder_uses(self, entity_name, date_string, service='nokia', amount=20, org=False):
    prefix = 'org' if org else 'user'
    date = datetime.strptime(date_string, "%Y%m%d")
    redis_name = "{0}:{1}:{2}:used_quota_month".format(prefix, entity_name, service)
    redis_key_month = "{0}_{1}".format(date.year, date.month)
    self.fake_redis_connection.hset(redis_name, redis_key_month, amount)
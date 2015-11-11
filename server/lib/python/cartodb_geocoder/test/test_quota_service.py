from mockredis import MockRedis
from cartodb_geocoder import quota_service
from unittest import TestCase
from nose.tools import assert_raises


class TestQuotaService(TestCase):

  def setUp(self):
    self.fake_redis_connection = MockRedis()
    self.fake_redis_connection.hset('geocoder:user_id','geocoding_quota', 100)
    self.fake_redis_connection.hset('geocoder:user_id','soft_geocoder_limit', 0)
    self.qs = quota_service.QuotaService('user_id', 'tx_id', redis_connection = self.fake_redis_connection)

  def test_should_return_true_if_quota_with_no_use(self):
    assert self.qs.check_user_quota() == True

  def test_should_return_true_if_quota_is_not_completely_used(self):
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id', 10)
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id_2', 10)
    assert self.qs.check_user_quota() == True

  def test_should_return_false_if_quota_is_surpassed(self):
    self.fake_redis_connection.hset('geocoder:user_id','geocoding_quota', 1)
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id', 10)
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id_2', 10)
    assert self.qs.check_user_quota() == False

  def test_should_return_true_if_quota_is_surpassed_but_soft_limit_is_enabled(self):
    self.fake_redis_connection.hset('geocoder:user_id','geocoding_quota', 1)
    self.fake_redis_connection.hset('geocoder:user_id','soft_geocoder_limit', 1)
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id', 10)
    self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id_2', 10)
    assert self.qs.check_user_quota() == True
from mockredis import MockRedis
from cartodb_geocoder import user_service
from unittest import TestCase
from nose.tools import assert_raises


class TestUserService(TestCase):

    def setUp(self):
      self.fake_redis_connection = MockRedis()
      self.us = user_service.UserService('user_id', redis_connection = self.fake_redis_connection)

    def test_user_quota_should_be_10(self):
      self.fake_redis_connection.hset('geocoder:user_id','geocoding_quota', 10)
      assert self.us.user_quota() == 10

    def test_should_return_0_if_negative_quota(self):
      self.fake_redis_connection.hset('geocoder:user_id','geocoding_quota', -10)
      assert self.us.user_quota() == 0

    def test_should_return_0_if_not_user(self):
      assert self.us.user_quota() == 0

    def test_user_used_quota_for_a_month(self):
      self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id', 10)
      self.fake_redis_connection.hset('geocoder:user_id:201511','tx_id_2', 10)
      assert self.us.used_quota_month(2015, 11) == 20

    def test_user_not_amount_in_used_quota_for_month_should_be_0(self):
      assert self.us.used_quota_month(2015, 11) == 0

    def test_increment_used_quota(self):
      self.us.increment_geocoder_use(2015, 11, 'tx_id', 1)
      assert self.us.used_quota_month(2015, 11) == 1

    def test_exception_if_not_redis_config(self):
      assert_raises(Exception, user_service.UserService, 'user_id')
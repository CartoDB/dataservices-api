from test_helper import *
from mockredis import MockRedis
from cartodb_services.metrics import UserMetricsService
from cartodb_services.metrics import GeocoderConfig
from datetime import datetime, date
from unittest import TestCase
from mock import Mock
from nose.tools import assert_raises
from datetime import timedelta
from freezegun import freeze_time


class TestUserService(TestCase):

    NOKIA_GEOCODER = 'geocoder_here'

    def setUp(self):
        self.redis_conn = MockRedis()

    def test_user_used_quota_for_a_day(self):
        us = self.__build_user_service('test_user')
        increment_service_uses(self.redis_conn, 'test_user',
                                           amount=400)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 400

    def test_user_quota_for_a_month_shorter_than_end_day(self):
        us = self.__build_user_service('test_user', end_date=datetime(2016,1,31))
        assert us.used_quota(self.NOKIA_GEOCODER, date(2016,2,10)) == 0

    def test_org_used_quota_for_a_day(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        increment_service_uses(self.redis_conn, 'test_user',
                                           orgname='test_org',
                                           amount=400)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 400

    def test_org_quota_quota_for_a_month_shorter_than_end_day(self):
        us = self.__build_user_service('test_user', orgname='test_org', end_date=datetime(2016,1,31))
        assert us.used_quota(self.NOKIA_GEOCODER, date(2016,2,10)) == 0

    def test_user_not_amount_in_used_quota_for_month_should_be_0(self):
        us = self.__build_user_service('test_user')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 0

    def test_org_not_amount_in_used_quota_for_month_should_be_0(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 0

    def test_should_increment_user_used_quota_for_one_date(self):
        us = self.__build_user_service('test_user')
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 1
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'failed_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2

    def test_should_increment_org_used_quota(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 1
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'failed_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2

    def test_should_increment_user_used_quota_in_for_multiples_dates(self):
        two_days_ago = datetime.today() - timedelta(days=2)
        one_day_ago = datetime.today() - timedelta(days=1)
        one_day_after = datetime.today() + timedelta(days=1)
        us = self.__build_user_service('test_user', end_date=one_day_ago)
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses',
                                 date=date.today())
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 1
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses',
                                 date=one_day_ago)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses',
                                 date=two_days_ago)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses',
                                 date=one_day_after)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'failed_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2

    @freeze_time("2015-06-01")
    def test_should_account_for_zero_paddded_keys(self):
        us = self.__build_user_service('test_user')
        self.redis_conn.zincrby('user:test_user:geocoder_here:success_responses:201506', '01', 400)
        assert us.used_quota(self.NOKIA_GEOCODER, date(2015, 6,1)) == 400

    @freeze_time("2015-06-15")
    def test_should_not_request_redis_twice_when_unneeded(self):
        class MockRedisWithCounter(MockRedis):
            def __init__(self):
                super(MockRedisWithCounter, self).__init__()
                self._zscore_counter = 0
            def zscore(self, *args):
                print args
                self._zscore_counter += 1
                return super(MockRedisWithCounter, self).zscore(*args)
            def zscore_counter(self):
                return self._zscore_counter
        self.redis_conn = MockRedisWithCounter()
        us = self.__build_user_service('test_user', end_date=datetime.today())
        us.used_quota(self.NOKIA_GEOCODER, date(2015, 6, 15))

        #('user:test_user:geocoder_here:success_responses:201506', 15)
        #('user:test_user:geocoder_here:empty_responses:201506', 15)
        #('user:test_user:geocoder_cache:success_responses:201506', 15)
        assert self.redis_conn.zscore_counter() == 3

    def test_should_write_zero_padded_dates(self):
        us = self.__build_user_service('test_user')
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses',
                                 date=date(2015,6,1))
        assert self.redis_conn.zscore('user:test_user:geocoder_here:success_responses:201506', '01') == 1
        assert self.redis_conn.zscore('user:test_user:geocoder_here:success_responses:201506',  '1') == None

    def test_orgs_should_write_zero_padded_dates(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses',
                                 amount=400,
                                 date=date(2015,6,1))
        assert self.redis_conn.zscore('org:test_org:geocoder_here:success_responses:201506', '01') == 400
        assert self.redis_conn.zscore('org:test_org:geocoder_here:success_responses:201506',  '1') == None


    def __build_user_service(self, username, service='geocoding', quota=100,
                             provider='heremaps', orgname=None,
                             soft_limit=False, end_date=datetime.today()):
        build_redis_user_config(self.redis_conn, username, service,
                                quota=quota, provider=provider,
                                soft_limit=soft_limit,
                                end_date=end_date)
        if orgname:
            build_redis_org_config(self.redis_conn, orgname, service,
                                   provider=provider, quota=quota,
                                   end_date=end_date)
        geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                         username, orgname)
        return UserMetricsService(geocoder_config, self.redis_conn)

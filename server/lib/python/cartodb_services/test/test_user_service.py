import test_helper
from mockredis import MockRedis
from cartodb_services.metrics import UserMetricsService
from cartodb_services.metrics import GeocoderConfig
from datetime import datetime, date
from unittest import TestCase
from nose.tools import assert_raises
from datetime import timedelta


class TestUserService(TestCase):

    NOKIA_GEOCODER = 'geocoder_here'

    def setUp(self):
        self.redis_conn = MockRedis()

    def test_user_used_quota_for_a_day(self):
        us = self.__build_user_service('test_user')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            amount=400)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 400

    def test_org_used_quota_for_a_day(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            orgname='test_org',
                                            amount=400)
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 400

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
        us.increment_service_use(self.NOKIA_GEOCODER, 'fail_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2

    def test_should_increment_org_used_quota(self):
        us = self.__build_user_service('test_user', orgname='test_org')
        us.increment_service_use(self.NOKIA_GEOCODER, 'success_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 1
        us.increment_service_use(self.NOKIA_GEOCODER, 'empty_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2
        us.increment_service_use(self.NOKIA_GEOCODER, 'fail_responses')
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
        us.increment_service_use(self.NOKIA_GEOCODER, 'fail_responses')
        assert us.used_quota(self.NOKIA_GEOCODER, date.today()) == 2

    def __build_user_service(self, username, quota=100, service='heremaps',
                             orgname=None, soft_limit=False,
                             end_date=datetime.today()):
        test_helper.build_redis_user_config(self.redis_conn, username,
                                            quota=quota, service=service,
                                            soft_limit=soft_limit,
                                            end_date=end_date)
        if orgname:
            test_helper.build_redis_org_config(self.redis_conn, orgname,
                                               quota=quota, end_date=end_date)
        geocoder_config = GeocoderConfig(self.redis_conn,
                                         username, orgname,
                                         'nokia_id', 'nokia_cod')
        return UserMetricsService(geocoder_config, self.redis_conn)

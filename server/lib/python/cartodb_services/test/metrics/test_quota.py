from unittest import TestCase
from mockredis import MockRedis
from ..test_helper import build_plpy_mock
from cartodb_services.metrics.quota import QuotaChecker
from cartodb_services.metrics import RoutingConfig
from datetime import datetime


class RoutingConfigMock(object):

    def __init__(self, **kwargs):
        self.__dict__ = kwargs


class TestQuotaChecker(TestCase):

    USERNAME = 'my_test_user'
    PERIOD_END_DATE = datetime(2016,10,20)
    SERVICE_TYPE = 'routing_mapzen'
    REDIS_KEY = 'user:{0}:{1}:success_responses:{2}{3}'.format(
        USERNAME,
        SERVICE_TYPE,
        PERIOD_END_DATE.year,
        PERIOD_END_DATE.month
    )

    def test_routing_quota_check_passes_when_enough_quota(self):
        user_service_config = RoutingConfigMock(
            username = self.USERNAME,
            organization = None,
            service_type = self.SERVICE_TYPE,
            monthly_quota = 1000,
            period_end_date = datetime.today(),
            soft_limit = False
        )
        redis_conn = MockRedis()
        redis_conn.zincrby(self.REDIS_KEY, self.PERIOD_END_DATE.day, 999)
        assert QuotaChecker(user_service_config, redis_conn).check() == True

    def test_routing_quota_check_fails_when_quota_exhausted(self):
        user_service_config = RoutingConfigMock(
            username = self.USERNAME,
            organization = None,
            service_type = self.SERVICE_TYPE,
            monthly_quota = 1000,
            period_end_date = datetime.today(),
            soft_limit = False
        )
        redis_conn = MockRedis()
        redis_conn.zincrby(self.REDIS_KEY, self.PERIOD_END_DATE.day, 1001)
        checker = QuotaChecker(user_service_config, redis_conn)
        assert checker.check() == False

    def test_routing_quota_check_fails_right_in_the_limit(self):
        """
        I have 1000 credits and I just spent 1000 today. I should not pass
        the check to perform the 1001th routing operation.
        """
        user_service_config = RoutingConfigMock(
            username = self.USERNAME,
            organization = None,
            service_type = self.SERVICE_TYPE,
            monthly_quota = 1000,
            period_end_date = datetime.today(),
            soft_limit = False
        )
        redis_conn = MockRedis()
        redis_conn.zincrby(self.REDIS_KEY, self.PERIOD_END_DATE.day, 1000)
        checker = QuotaChecker(user_service_config, redis_conn)
        assert checker.check() == False

    def test_routing_quota_check_passes_if_no_quota_but_soft_limit(self):
        user_service_config = RoutingConfigMock(
            username = self.USERNAME,
            organization = None,
            service_type = self.SERVICE_TYPE,
            monthly_quota = 1000,
            period_end_date = datetime.today(),
            soft_limit = True
        )
        redis_conn = MockRedis()
        redis_conn.zincrby(self.REDIS_KEY, self.PERIOD_END_DATE.day, 1001)
        checker = QuotaChecker(user_service_config, redis_conn)
        assert checker.check() == True

import test_helper
from mockredis import MockRedis
from cartodb_services.metrics import QuotaService
from cartodb_services.metrics import GeocoderConfig
from unittest import TestCase
from nose.tools import assert_raises
from datetime import datetime, date


class TestQuotaService(TestCase):

    # single user
    #   user:<username>:<service>:<metric>:YYYYMM:DD
    # organization user
    #   org:<orgname>:<service>:<metric>:YYYYMM:DD

    def setUp(self):
        self.redis_conn = MockRedis()

    def test_should_return_true_if_user_quota_with_no_use(self):
        qs = self.__build_quota_service('test_user')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_with_no_use(self):
        qs = self.__build_quota_service('test_user', orgname='test_org')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_user_quota_is_not_completely_used(self):
        qs = self.__build_quota_service('test_user')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_is_not_completely_used(self):
        qs = self.__build_quota_service('test_user', orgname='test_org')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            orgname='test_org')
        assert qs.check_user_quota() is True

    def test_should_return_false_if_user_quota_is_surpassed(self):
        qs = self.__build_quota_service('test_user')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            amount=300)
        assert qs.check_user_quota() is False

    def test_should_return_false_if_org_quota_is_surpassed(self):
        qs = self.__build_quota_service('test_user', orgname='test_org')
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            orgname='test_org', amount=400)
        assert qs.check_user_quota() is False

    def test_should_return_true_if_user_quota_is_surpassed_but_soft_limit_is_enabled(self):
        qs = self.__build_quota_service('test_user', soft_limit=True)
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            amount=300)
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_is_surpassed_but_soft_limit_is_enabled(self):
        qs = self.__build_quota_service('test_user', orgname='test_org',
                                        soft_limit=True)
        test_helper.increment_geocoder_uses(self.redis_conn, 'test_user',
                                            orgname='test_org', amount=400)
        assert qs.check_user_quota() is True

    def test_should_check_user_increment_and_quota_check_correctly(self):
        qs = self.__build_quota_service('test_user', quota=2)
        qs.increment_success_geocoder_use()
        assert qs.check_user_quota() is True
        qs.increment_success_geocoder_use(amount=2)
        assert qs.check_user_quota() is False
        month = date.today().strftime('%Y%m')

    def test_should_check_org_increment_and_quota_check_correctly(self):
        qs = self.__build_quota_service('test_user', orgname='test_org',
                                        quota=2)
        qs.increment_success_geocoder_use()
        assert qs.check_user_quota() is True
        qs.increment_success_geocoder_use(amount=2)
        assert qs.check_user_quota() is False
        month = date.today().strftime('%Y%m')

    def __build_quota_service(self, username, quota=100, service='heremaps',
                              orgname=None, soft_limit=False,
                              end_date = datetime.today()):
        test_helper.build_redis_user_config(self.redis_conn, username,
                                            quota = quota, service = service,
                                            soft_limit = soft_limit,
                                            end_date = end_date)
        if orgname:
            test_helper.build_redis_org_config(self.redis_conn, orgname,
                                               quota=quota, end_date=end_date)
        geocoder_config = GeocoderConfig(self.redis_conn,
                                         username, orgname,
                                        'nokia_id', 'nokia_cod')
        return QuotaService(geocoder_config,
                             redis_connection = self.redis_conn)


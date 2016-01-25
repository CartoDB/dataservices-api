import test_helper
from mockredis import MockRedis
from cartodb_geocoder import quota_service
from cartodb_geocoder import config_helper
from unittest import TestCase
from nose.tools import assert_raises
from datetime import datetime, date


class TestQuotaService(TestCase):

    # single user
    #   user:<username>:<service>:<metric>:YYYYMM:DD
    # organization user
    #   org:<orgname>:<service>:<metric>:YYYYMM:DD

# def increment_geocoder_uses(self, username, orgname=None,
#                             date=date.today(), service='geocoder_here',
#                             metric='success_responses', amount=20):

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
        assert qs.check_user_quota() == True
        qs.increment_success_geocoder_use(amount=2)
        assert qs.check_user_quota() == False
        month = date.today().strftime('%Y%m')
        name = 'user:test_user:geocoder_here:total_requests:{0}'.format(month)
        total_requests = self.redis_conn.zscore(name, date.today().day)
        assert total_requests == 3

    def test_should_check_org_increment_and_quota_check_correctly(self):
        qs = self.__build_quota_service('test_user', orgname='test_org',
                                        quota=2)
        qs.increment_success_geocoder_use()
        assert qs.check_user_quota() == True
        qs.increment_success_geocoder_use(amount=2)
        assert qs.check_user_quota() == False
        month = date.today().strftime('%Y%m')
        org_name = 'org:test_org:geocoder_here:total_requests:{0}'.format(month)
        org_total_requests = self.redis_conn.zscore(org_name, date.today().day)
        assert org_total_requests == 3
        user_name = 'user:test_user:geocoder_here:total_requests:{0}'.format(month)
        user_total_requests = self.redis_conn.zscore(user_name, date.today().day)
        assert user_total_requests == 3

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
        geocoder_config = config_helper.GeocoderConfig(self.redis_conn,
                                                       username, orgname,
                                                       'nokia_id', 'nokia_cod')
        return quota_service.QuotaService(geocoder_config,
                                          redis_connection = self.redis_conn)


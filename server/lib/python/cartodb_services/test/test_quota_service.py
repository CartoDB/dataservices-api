from test_helper import *
from mockredis import MockRedis
from cartodb_services.metrics import QuotaService
from cartodb_services.metrics import *
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
        qs = self.__build_geocoder_quota_service('test_user')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_with_no_use(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='test_org')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_user_quota_is_not_completely_used(self):
        qs = self.__build_geocoder_quota_service('test_user')
        increment_service_uses(self.redis_conn, 'test_user')
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_is_not_completely_used(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='test_org')
        increment_service_uses(self.redis_conn, 'test_user',
                               orgname='test_org')
        assert qs.check_user_quota() is True

    def test_should_return_false_if_user_quota_is_surpassed(self):
        qs = self.__build_geocoder_quota_service('test_user')
        increment_service_uses(self.redis_conn, 'test_user',
                               amount=300)
        assert qs.check_user_quota() is False

    def test_should_return_false_if_org_quota_is_surpassed(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='test_org')
        increment_service_uses(self.redis_conn, 'test_user',
                               orgname='test_org', amount=400)
        assert qs.check_user_quota() is False

    def test_should_return_true_if_user_quota_is_surpassed_but_soft_limit_is_enabled(self):
        qs = self.__build_geocoder_quota_service('test_user', soft_limit=True)
        increment_service_uses(self.redis_conn, 'test_user',
                               amount=300)
        assert qs.check_user_quota() is True

    def test_should_return_true_if_org_quota_is_surpassed_but_soft_limit_is_enabled(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='test_org',
                                                 soft_limit=True)
        increment_service_uses(self.redis_conn, 'test_user',
                               orgname='test_org', amount=400)
        assert qs.check_user_quota() is True

    def test_should_check_user_increment_and_quota_check_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user', quota=2)
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=2)
        assert qs.check_user_quota() is False

    def test_should_check_org_increment_and_quota_check_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user', quota=2,
                                                 orgname='test_org')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=2)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapzen_geocoder_quota_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 provider='mapzen')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapzen_geocoder_quota_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='testorg',
                                                 provider='mapzen')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapbox_geocoder_quota_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 provider='mapbox')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapbox_geocoder_quota_correctly(self):
        qs = self.__build_geocoder_quota_service('test_user',
                                                 orgname='testorg',
                                                 provider='mapbox')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapzen_routing_quota_correctly(self):
        qs = self.__build_routing_quota_service('test_user', provider='mapzen')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapzen_routing_quota_correctly(self):
        qs = self.__build_routing_quota_service('test_user', provider='mapzen',
                                                orgname='testorg')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapbox_routing_quota_correctly(self):
        qs = self.__build_routing_quota_service('test_user', provider='mapbox')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapbox_routing_quota_correctly(self):
        qs = self.__build_routing_quota_service('test_user', provider='mapbox',
                                                orgname='testorg')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapzen_isolines_quota_correctly(self):
        qs = self.__build_isolines_quota_service('test_user',
                                                 provider='mapzen')
        qs.increment_isolines_service_use()
        assert qs.check_user_quota() is True
        qs.increment_isolines_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapzen_isolines_quota_correctly(self):
        qs = self.__build_isolines_quota_service('test_user',
                                                 provider='mapzen',
                                                 orgname='testorg')
        qs.increment_isolines_service_use()
        assert qs.check_user_quota() is True
        qs.increment_isolines_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_user_mapbox_isolines_quota_correctly(self):
        qs = self.__build_isolines_quota_service('test_user',
                                                 provider='mapbox')
        qs.increment_isolines_service_use()
        assert qs.check_user_quota() is True
        qs.increment_isolines_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    def test_should_check_org_mapbox_isolines_quota_correctly(self):
        qs = self.__build_isolines_quota_service('test_user',
                                                 provider='mapbox',
                                                 orgname='testorg')
        qs.increment_isolines_service_use()
        assert qs.check_user_quota() is True
        qs.increment_isolines_service_use(amount=1500000)
        assert qs.check_user_quota() is False

    # Quick workaround so we don't take into account numer of credits
    # spent for users that have defined the quota.
    # See https://github.com/CartoDB/bigmetadata/issues/215
    def test_should_check_user_obs_snapshot_quota_correctly(self):
        qs = self.__build_obs_snapshot_quota_service('test_user')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=100000)
        assert qs.check_user_quota() is True

    def test_should_check_org_obs_snapshot_quota_correctly(self):
        qs = self.__build_obs_snapshot_quota_service('test_user',
                                                     orgname='testorg')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=100000)
        assert qs.check_user_quota() is True

    def test_should_check_user_obs_quota_correctly(self):
        qs = self.__build_obs_snapshot_quota_service('test_user')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=100000)
        assert qs.check_user_quota() is True

    def test_should_check_org_obs_quota_correctly(self):
        qs = self.__build_obs_quota_service('test_user',
                                            orgname='testorg')
        qs.increment_success_service_use()
        assert qs.check_user_quota() is True
        qs.increment_success_service_use(amount=100000)
        assert qs.check_user_quota() is True

    def __prepare_quota_service(self, username, service, quota, provider,
                                orgname, soft_limit, end_date):
        build_redis_user_config(self.redis_conn, username, service,
                                quota=quota, provider=provider,
                                soft_limit=soft_limit, end_date=end_date)
        if orgname:
            build_redis_org_config(self.redis_conn, orgname, service,
                                   quota=quota, provider=provider,
                                   end_date=end_date)

    def __build_geocoder_quota_service(self, username, quota=100,
                                       provider='heremaps', orgname=None,
                                       soft_limit=False,
                                       end_date=datetime.today()):
        self.__prepare_quota_service(username, 'geocoding', quota,
                                     provider, orgname, soft_limit, end_date)
        geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                         username, orgname)
        return QuotaService(geocoder_config, redis_connection=self.redis_conn)

    def __build_routing_quota_service(self, username, provider,
                                      orgname=None, soft_limit=False,
                                      quota=100, end_date=datetime.today()):
        self.__prepare_quota_service(username, 'routing', quota, provider,
                                     orgname, soft_limit, end_date)
        routing_config = RoutingConfig(self.redis_conn, plpy_mock,
                                       username, orgname)
        return QuotaService(routing_config, redis_connection=self.redis_conn)

    def __build_isolines_quota_service(self, username, provider,
                                      orgname=None, soft_limit=False,
                                      quota=100, end_date=datetime.today()):
        self.__prepare_quota_service(username, 'isolines', quota, provider,
                                     orgname, soft_limit, end_date)
        isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                               username, orgname)
        return QuotaService(isolines_config, redis_connection=self.redis_conn)

    def __build_obs_snapshot_quota_service(self, username, quota=100,
                                           provider='obs_snapshot',
                                           orgname=None,
                                           soft_limit=False,
                                           end_date=datetime.today()):
        self.__prepare_quota_service(username, 'data_observatory', quota,
                                     None, orgname, soft_limit, end_date)
        do_config = ObservatorySnapshotConfig(self.redis_conn, plpy_mock,
                                          username, orgname)
        return QuotaService(do_config, redis_connection=self.redis_conn)

    def __build_obs_quota_service(self, username, quota=100,
                                  provider='obs_general',
                                  orgname=None,
                                  soft_limit=False,
                                  end_date=datetime.today()):
        self.__prepare_quota_service(username, 'data_observatory', quota,
                                     None, orgname, soft_limit, end_date)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                          username, orgname)
        return QuotaService(do_config, redis_connection=self.redis_conn)

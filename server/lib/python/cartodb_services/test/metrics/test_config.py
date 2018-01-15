from unittest import TestCase
from mockredis import MockRedis
from datetime import datetime, timedelta
from ..test_helper import *
from cartodb_services.metrics.config import *


class TestGeocoderUserConfig(TestCase):

    GEOCODER_PROVIDERS = ['heremaps', 'mapzen', 'mapbox', 'google']

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_geocoder_config_for_user(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    provider=geocoder_provider, quota=100)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            if geocoder_provider == 'heremaps':
                assert geocoder_config.heremaps_geocoder is True
                assert geocoder_config.geocoding_quota == 100
            elif geocoder_provider == 'mapzen':
                assert geocoder_config.mapzen_geocoder is True
                assert geocoder_config.geocoding_quota == 100
            elif geocoder_provider == 'mapbox':
                assert geocoder_config.mapbox_geocoder is True
                assert geocoder_config.geocoding_quota == 100
            elif geocoder_provider == 'google':
                assert geocoder_config.google_geocoder is True
                assert geocoder_config.geocoding_quota is None
            assert geocoder_config.soft_geocoding_limit is False

    def test_should_return_quota_0_when_is_0_in_redis(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota=0, provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            if geocoder_provider is not 'google':
                assert geocoder_config.geocoding_quota == 0

    def test_should_return_quota_0_if_quota_is_empty(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota='', provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            if geocoder_provider is not 'google':
                assert geocoder_config.geocoding_quota == 0

    def test_should_return_quota_None_when_is_provider_is_google(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota=0, provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            if geocoder_provider is 'google':
                assert geocoder_config.geocoding_quota == None

    def test_should_return_true_if_soft_limit_is_true(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota=0, soft_limit=True,
                                    provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            assert geocoder_config.soft_geocoding_limit == True

    def test_should_return_false_if_soft_limit_is_empty_string(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota=0, soft_limit='',
                                    provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', None)
            assert geocoder_config.soft_geocoding_limit == False


class TestGeocoderOrgConfig(TestCase):

    GEOCODER_PROVIDERS = ['heremaps', 'mapzen', 'mapbox', 'google']

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_org_config(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            yesterday = datetime.today() - timedelta(days=1)

            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    provider=geocoder_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'geocoding',
                                   quota=200, end_date=yesterday,
                                   provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', 'test_org')
            if geocoder_provider == 'heremaps':
                assert geocoder_config.heremaps_geocoder is True
                assert geocoder_config.geocoding_quota == 200
            elif geocoder_provider == 'mapzen':
                assert geocoder_config.mapzen_geocoder is True
                assert geocoder_config.geocoding_quota == 200
            elif geocoder_provider == 'mapbox':
                assert geocoder_config.mapbox_geocoder is True
                assert geocoder_config.geocoding_quota == 200
            elif geocoder_provider == 'google':
                assert geocoder_config.google_geocoder is True
                assert geocoder_config.geocoding_quota is None
            assert geocoder_config.soft_geocoding_limit is False
            assert geocoder_config.period_end_date.date() == yesterday.date()

    def test_should_return_0_quota_if_has_0_in_redis_config(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            yesterday = datetime.today() - timedelta(days=1)
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    provider=geocoder_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'geocoding',
                                   quota=0, end_date=yesterday,
                                   provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                            'test_user', 'test_org')
            if geocoder_provider is not 'google':
                assert geocoder_config.geocoding_quota == 0

    def test_should_return_0_if_quota_is_empty_for_org_in_redis(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            yesterday = datetime.today() - timedelta(days=1)
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    provider=geocoder_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'geocoding',
                                   quota='', end_date=yesterday,
                                   provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                         'test_user', 'test_org')
            if geocoder_provider is not 'google':
                assert geocoder_config.geocoding_quota == 0

    def test_should_return_None_if_provider_is_google(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            yesterday = datetime.today() - timedelta(days=1)
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    provider=geocoder_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'geocoding',
                                   quota='', end_date=yesterday,
                                   provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                         'test_user', 'test_org')
            if geocoder_provider is 'google':
                assert geocoder_config.geocoding_quota == None

    def test_should_return_user_quota_if_is_not_defined_for_org(self):
        for geocoder_provider in self.GEOCODER_PROVIDERS:
            yesterday = datetime.today() - timedelta(days=1)
            build_redis_user_config(self.redis_conn, 'test_user', 'geocoding',
                                    quota=100, provider=geocoder_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'geocoding',
                                   quota=None, end_date=yesterday,
                                   provider=geocoder_provider)
            geocoder_config = GeocoderConfig(self.redis_conn, plpy_mock,
                                         'test_user', 'test_org')
            if geocoder_provider is not 'google':
                assert geocoder_config.geocoding_quota == 100


class TestIsolinesUserConfig(TestCase):
    ISOLINES_PROVIDERS = ['heremaps', 'mapzen', 'mapbox']

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_user_config_for_isolines(self):
        for isolines_provider in self.ISOLINES_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    quota=100, provider=isolines_provider)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user')
            if isolines_provider is 'mapzen':
                assert isolines_config.service_type is 'mapzen_isolines'
            elif isolines_provider is 'mapbox':
                assert isolines_config.service_type is 'mapbox_isolines'
            else:
                assert isolines_config.service_type is 'here_isolines'
            assert isolines_config.isolines_quota == 100
            assert isolines_config.soft_isolines_limit is False

    def test_should_return_0_quota_for_0_value(self):
        for isolines_provider in self.ISOLINES_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider, quota=0,
                                    soft_limit=True)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user')
            assert isolines_config.isolines_quota == 0

    def test_should_return_0_quota_for_empty_quota_value(self):
        for isolines_provider in self.ISOLINES_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider, quota='')
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user')
            assert isolines_config.isolines_quota == 0

    def test_should_return_true_soft_limit(self):
        for isolines_provider in self.ISOLINES_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider, quota=0,
                                    soft_limit=True)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user')
            assert isolines_config.soft_isolines_limit is True

    def test_should_return_false_soft_limit_with_empty_string(self):
        for isolines_provider in self.ISOLINES_PROVIDERS:
            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider, quota=0,
                                    soft_limit='')
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user')
            assert isolines_config.soft_isolines_limit is False


class TestIsolinesOrgConfig(TestCase):

    ISOLINES_PROVIDERS = ['heremaps', 'mapzen', 'mapbox']

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_org_config_for_isolines(self):
        yesterday = datetime.today() - timedelta(days=1)
        for isolines_provider in self.ISOLINES_PROVIDERS:

            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'isolines',
                                   quota=200, end_date=yesterday,
                                   provider=isolines_provider)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user', 'test_org')
            assert isolines_config.isolines_quota == 200
            assert isolines_config.soft_isolines_limit is False
            assert isolines_config.period_end_date.date() == yesterday.date()

    def test_should_return_quota_0_for_0_redis_quota(self):
        yesterday = datetime.today() - timedelta(days=1)
        for isolines_provider in self.ISOLINES_PROVIDERS:

            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider,
                                    soft_limit=True)
            build_redis_org_config(self.redis_conn, 'test_org', 'isolines',
                                   quota=0, end_date=yesterday,
                                   provider=isolines_provider)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user', 'test_org')
            assert isolines_config.isolines_quota == 0

    def test_should_return_quota_0_for_empty_string_quota_in_org_config(self):
        yesterday = datetime.today() - timedelta(days=1)
        for isolines_provider in self.ISOLINES_PROVIDERS:

            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider)
            build_redis_org_config(self.redis_conn, 'test_org', 'isolines',
                                   quota='', end_date=yesterday,
                                   provider=isolines_provider)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user', 'test_org')
            assert isolines_config.isolines_quota == 0

    def test_should_return_user_quota_for_non_existent_org_quota(self):
        yesterday = datetime.today() - timedelta(days=1)
        for isolines_provider in self.ISOLINES_PROVIDERS:

            build_redis_user_config(self.redis_conn, 'test_user', 'isolines',
                                    provider=isolines_provider, quota=100)
            build_redis_org_config(self.redis_conn, 'test_org', 'isolines',
                                   quota=None, end_date=yesterday,
                                   provider=isolines_provider)
            isolines_config = IsolinesRoutingConfig(self.redis_conn, plpy_mock,
                                                    'test_user', 'test_org')
            assert isolines_config.isolines_quota == 100


class TestRoutingConfig(TestCase):

    def setUp(self):
        self._redis_conn = MockRedis()
        self._db_conn = plpy_mock
        self._username = 'my_test_user'
        self._user_key = "rails:users:{0}".format(self._username)
        self._redis_conn.hset(self._user_key, 'period_end_date', '2016-10-10')

    def test_should_pick_quota_from_redis_if_present(self):
        self._redis_conn.hset(self._user_key, 'mapzen_routing_quota', 1000)
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.monthly_quota == 1000

    def test_org_quota_overrides_user_quota(self):
        self._redis_conn.hset(self._user_key, 'mapzen_routing_quota', 1000)
        orgname = 'my_test_org'
        orgname_key = "rails:orgs:{0}".format(orgname)
        self._redis_conn.hset(orgname_key, 'period_end_date', '2016-05-31')
        self._redis_conn.hset(orgname_key, 'mapzen_routing_quota', 5000)

        # TODO: these are not too relevant for the routing config
        self._redis_conn.hset(orgname_key, 'geocoding_quota', 0)
        self._redis_conn.hset(orgname_key, 'here_isolines_quota', 0)

        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.monthly_quota == 5000

    def test_should_have_soft_limit_false_by_default(self):
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.soft_limit == False

    def test_can_set_soft_limit_in_user_conf(self):
        self._redis_conn.hset(self._user_key, 'soft_mapzen_routing_limit', True)
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.soft_limit == True


class TestDataObservatoryUserConfig(TestCase):

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_config_for_obs_snapshot(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100, end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn, plpy_mock,
                                          'test_user')
        assert do_config.monthly_quota == 100
        assert do_config.soft_limit is False
        assert do_config.period_end_date.date() == yesterday.date()

    def test_should_return_true_if_soft_limit_is_true_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=0, soft_limit=True, end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn, plpy_mock,
                                          'test_user')
        assert do_config.soft_limit is True

    def test_should_return_0_if_quota_is_0_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=0, end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn, plpy_mock,
                                              'test_user')
        assert do_config.monthly_quota == 0

    def test_should_return_0_if_quota_is_empty_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota='', end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn, plpy_mock,
                                              'test_user')
        assert do_config.monthly_quota == 0

    def test_should_return_config_for_obs_snapshot(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                          'test_user')
        assert do_config.monthly_quota == 100
        assert do_config.soft_limit is False
        assert do_config.period_end_date.date() == yesterday.date()

    def test_should_return_0_if_quota_is_0_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=0, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                              'test_user')
        assert do_config.monthly_quota == 0

    def test_should_return_0_if_quota_is_empty_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota='', end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                              'test_user')
        assert do_config.monthly_quota == 0

    def test_should_return_true_if_soft_limit_is_true_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=0, soft_limit=True, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                          'test_user')
        assert do_config.soft_limit is True

    def test_should_return_true_if_soft_limit_is_empty_string_in_redis(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=0, soft_limit='', end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                          'test_user')
        assert do_config.soft_limit is False

class TestDataObservatoryOrgConfig(TestCase):

    def setUp(self):
        self.redis_conn = MockRedis()
        plpy_mock_config()

    def test_should_return_organization_config(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100, end_date=yesterday)
        build_redis_org_config(self.redis_conn, 'test_org', 'data_observatory',
                                quota=200, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                      'test_user', 'test_org')
        assert do_config.monthly_quota == 200
        assert do_config.period_end_date.date() == yesterday.date()

    def test_should_return_quota_0_for_0_in_org_quota_config(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100)
        build_redis_org_config(self.redis_conn, 'test_org', 'data_observatory',
                                quota=0, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                      'test_user', 'test_org')
        assert do_config.monthly_quota == 0

    def test_should_return_quota_0_for_empty_in_org_quota_config(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100)
        build_redis_org_config(self.redis_conn, 'test_org', 'data_observatory',
                                quota='', end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                      'test_user', 'test_org')
        assert do_config.monthly_quota == 0

    def test_should_return_user_config_when_org_quota_is_not_defined(self):
        yesterday = datetime.today() - timedelta(days=1)
        build_redis_user_config(self.redis_conn, 'test_user', 'data_observatory',
                                quota=100)
        build_redis_org_config(self.redis_conn, 'test_org', 'data_observatory',
                                quota=None, end_date=yesterday)
        do_config = ObservatoryConfig(self.redis_conn, plpy_mock,
                                      'test_user', 'test_org')
        assert do_config.monthly_quota == 100


class TestServicesRedisConfig(TestCase):
    def test_it_picks_mapzen_routing_quota_from_redis(self):
        redis_conn = MockRedis()
        redis_conn.hset('rails:users:my_username', 'mapzen_routing_quota', 42)
        redis_config = ServicesRedisConfig(redis_conn).build('my_username', None)
        assert 'mapzen_routing_quota' in redis_config
        assert int(redis_config['mapzen_routing_quota']) == 42

    def test_org_quota_overrides_user_quota(self):
        redis_conn = MockRedis()
        redis_conn.hset('rails:users:my_username', 'mapzen_routing_quota', 42)
        redis_conn.hset('rails:orgs:acme', 'mapzen_routing_quota', 31415)
        redis_config = ServicesRedisConfig(redis_conn).build('my_username', 'acme')
        assert 'mapzen_routing_quota' in redis_config
        assert int(redis_config['mapzen_routing_quota']) == 31415

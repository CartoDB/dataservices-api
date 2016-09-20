import test_helper
from cartodb_services.metrics import GeocoderConfig, ObservatorySnapshotConfig, ConfigException
from unittest import TestCase
from nose.tools import assert_raises
from mockredis import MockRedis
from datetime import datetime, timedelta
from cartodb_services.config.server_config import ServerConfigFactory, DummyServerConfig
import cartodb_services


class TestConfig(TestCase):

    def setUp(self):
        self.redis_conn = MockRedis()
        self.plpy_mock = test_helper.build_plpy_mock()

    def tearDown(self):
        ServerConfigFactory._reset()

    def test_should_return_list_of_nokia_geocoder_config_if_its_ok(self):
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        import json
        config_mock = DummyServerConfig({
            # TODO the geocoder should not require all the config to be there
            'server_conf': {
                "environment": "testing"
            },
            'heremaps_conf': {
                "geocoder": {"app_id": "app_id", "app_code": "code", "geocoder_cost_per_hit": 1},
                "isolines": {"app_id": "app_id", "app_code": "code"}
            },
            'mapzen_conf': {
                "routing": {"api_key": "api_key_rou", "monthly_quota": 1500000},
                "geocoder": {"api_key": "api_key_geo", "monthly_quota": 1500000},
                "matrix": {"api_key": "api_key_mat", "monthly_quota": 1500000}
            },
            'logger_conf': {
                "geocoder_log_path": "/dev/null"
            },
            'data_observatory_conf': {
                "connection": {
                    "whitelist": ["ethervoid"],
                    "production": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api",
                    "staging": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api"}
            }
        })
        ServerConfigFactory._set(config_mock)
        cartodb_services.init(_plpy=None, _GD={})
        #from nose.tools import set_trace; set_trace()
        geocoder_config = GeocoderConfig('test_user', None)
        assert geocoder_config.heremaps_geocoder is True
        assert geocoder_config.geocoding_quota == 100
        assert geocoder_config.soft_geocoding_limit is False

    def test_should_return_list_of_nokia_geocoder_config_ok_for_org(self):
        yesterday = datetime.today() - timedelta(days=1)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        test_helper.build_redis_org_config(self.redis_conn, 'test_org',
                                           quota=200, end_date=yesterday)
        geocoder_config = GeocoderConfig(self.redis_conn, self.plpy_mock,
                                         'test_user', 'test_org')
        assert geocoder_config.heremaps_geocoder is True
        assert geocoder_config.geocoding_quota == 200
        assert geocoder_config.soft_geocoding_limit is False
        assert geocoder_config.period_end_date.date() == yesterday.date()

    def test_should_return_config_for_obs_snapshot(self):
        yesterday = datetime.today() - timedelta(days=1)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user',
                                            do_quota=100, soft_do_limit=True,
                                            end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn,
                                          'test_user')
        assert do_config.monthly_quota == 100
        assert do_config.soft_limit is True
        assert do_config.period_end_date.date() == yesterday.date()

    def test_should_return_db_quota_if_not_redis_quota_config_obs_snapshot(self):
        yesterday = datetime.today() - timedelta(days=1)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user',
                                            end_date=yesterday)
        do_config = ObservatorySnapshotConfig(self.redis_conn, self.plpy_mock,
                                          'test_user')
        assert do_config.monthly_quota == 0
        assert do_config.soft_limit is False
        assert do_config.period_end_date.date() == yesterday.date()

    def test_should_raise_exception_when_missing_parameters(self):
        plpy_mock = test_helper.build_plpy_mock(empty=True)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        assert_raises(ConfigException, GeocoderConfig, self.redis_conn,
                      'test_user', None)

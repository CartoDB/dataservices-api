import test_helper
from cartodb_services.metrics import GeocoderConfig, ConfigException
from unittest import TestCase
from nose.tools import assert_raises
from mockredis import MockRedis
from datetime import datetime, timedelta


class TestConfig(TestCase):

    def setUp(self):
        self.redis_conn = MockRedis()
        self.plpy_mock = test_helper.build_plpy_mock()

    def test_should_return_list_of_nokia_geocoder_config_if_its_ok(self):
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        geocoder_config = GeocoderConfig(self.redis_conn, self.plpy_mock,
                                         'test_user', None)
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

    def test_should_raise_exception_when_missing_parameters(self):
        plpy_mock = test_helper.build_plpy_mock(empty=True)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        assert_raises(ConfigException,
                      GeocoderConfig,
                      self.redis_conn, plpy_mock, 'test_user',
                      None)

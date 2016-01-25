import test_helper
from cartodb_geocoder import config_helper
from unittest import TestCase
from nose.tools import assert_raises
from mockredis import MockRedis
from datetime import datetime, timedelta


class TestConfigHelper(TestCase):

    def setUp(self):
        self.redis_conn = MockRedis()

    def test_should_return_list_of_nokia_geocoder_config_if_its_ok(self):
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        geocoder_config = config_helper.GeocoderConfig(self.redis_conn,
                                                       'test_user', None,
                                                       'nokia_id', 'nokia_cod')
        assert geocoder_config.heremaps_geocoder == True
        assert geocoder_config.geocoding_quota == 100
        assert geocoder_config.soft_geocoding_limit == False

    def test_should_return_list_of_nokia_geocoder_config_ok_for_org(self):
        yesterday = datetime.today() - timedelta(days=1)
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        test_helper.build_redis_org_config(self.redis_conn, 'test_org',
                                           quota=200, end_date=yesterday)
        geocoder_config = config_helper.GeocoderConfig(self.redis_conn,
                                                       'test_user', 'test_org',
                                                       'nokia_id', 'nokia_cod')
        assert geocoder_config.heremaps_geocoder == True
        assert geocoder_config.geocoding_quota == 200
        assert geocoder_config.soft_geocoding_limit == False
        assert geocoder_config.period_end_date.date() == yesterday.date()

    def test_should_raise_configuration_exception_when_missing_nokia_geocoder_parameters(self):
        test_helper.build_redis_user_config(self.redis_conn, 'test_user')
        assert_raises(config_helper.ConfigException,
                      config_helper.GeocoderConfig,
                      self.redis_conn, 'test_user',
                      None, None, None)

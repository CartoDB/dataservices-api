from test_helper import *
from unittest import TestCase
from mock import Mock, MagicMock, patch
from nose.tools import assert_raises, assert_not_equal, assert_equal

from datetime import datetime, date
from cartodb_services.tools import ServiceManager, LegacyServiceManager
from mockredis import MockRedis
import cartodb_services
from cartodb_services.metrics import GeocoderConfig
from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder
from cartodb_services.refactor.backend.redis_metrics_connection import RedisConnectionBuilder
from cartodb_services.tools import RateLimitExceeded

LUA_AVAILABLE_FOR_MOCKREDIS = False

class MockRedisWithVersionInfo(MockRedis):
    def info(self):
        return {'redis_version': '3.0.2'}

class TestServiceManager(TestCase):

    def setUp(self):
        plpy_mock_config()
        cartodb_services.init(plpy_mock, _GD={})
        self.username = 'test_user'
        self.orgname = 'test_org'
        self.redis_conn = MockRedisWithVersionInfo()
        build_redis_user_config(self.redis_conn, self.username, 'geocoding')
        build_redis_org_config(self.redis_conn, self.orgname, 'geocoding', provider='mapzen')
        self.environment = 'production'
        plpy_mock._define_result("CDB_Conf_GetConf\('server_conf'\)", [{'conf': '{"environment": "production"}'}])
        plpy_mock._define_result("CDB_Conf_GetConf\('redis_metadata_config'\)", [{'conf': '{"redis_host":"localhost","redis_port":"6379"}'}])
        plpy_mock._define_result("CDB_Conf_GetConf\('redis_metrics_config'\)", [{'conf': '{"redis_host":"localhost","redis_port":"6379"}'}])

    def check_rate_limit(self, service_manager, n, active=True):
        if LUA_AVAILABLE_FOR_MOCKREDIS:
            for _ in xrange(n):
                service_manager.assert_within_limits()
            if active:
                with assert_raises(RateLimitExceeded):
                    service_manager.assert_within_limits()
            else:
                service_manager.assert_within_limits()
        else:
            # rratelimit doesn't work with MockRedis because it needs Lua support
            # so, we'll simply perform some sanity check on the configuration of the rate limiter
            if active:
                assert_equal(service_manager.rate_limiter._config.is_limited(), True)
                assert_equal(service_manager.rate_limiter._config.limit, n)
            else:
                assert not service_manager.rate_limiter._config.is_limited()

    def test_legacy_service_manager(self):
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        service_manager.assert_within_limits()
        assert_equal(service_manager.config.service_type, 'geocoder_mapzen')

    def test_service_manager(self):
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            service_manager.assert_within_limits()
            assert_equal(service_manager.config.service_type, 'geocoder_mapzen')

    def test_no_rate_limit_by_default(self):
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3, False)

    def test_no_legacy_rate_limit_by_default(self):
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3, False)

    def test_legacy_server_rate_limit(self):
        rate_limits = '{"geocoder":{"limit":"3","period":3600}}'
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': rate_limits}])
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3)
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])

    def test_server_rate_limit(self):
        rate_limits = '{"geocoder":{"limit":"3","period":3600}}'
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': rate_limits}])
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3)
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])

    def test_user_rate_limit(self):
        user_redis_name = "rails:users:{0}".format(self.username)
        rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(user_redis_name, 'geocoder_rate_limit', rate_limits)
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(user_redis_name, 'geocoder_rate_limit')

    def test_legacy_user_rate_limit(self):
        user_redis_name = "rails:users:{0}".format(self.username)
        rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(user_redis_name, 'geocoder_rate_limit', rate_limits)
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(user_redis_name, 'geocoder_rate_limit')

    def test_org_rate_limit(self):
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', rate_limits)
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')

    def test_legacy_org_rate_limit(self):
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', rate_limits)
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')

    def test_user_rate_limit_precedence_over_org(self):
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        org_rate_limits = '{"limit":"1000","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', org_rate_limits)
        user_redis_name = "rails:users:{0}".format(self.username)
        user_rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(user_redis_name, 'geocoder_rate_limit', user_rate_limits)
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')
        self.redis_conn.hdel(user_redis_name, 'geocoder_rate_limit')

    def test_org_rate_limit_precedence_over_server(self):
        server_rate_limits = '{"geocoder":{"limit":"1000","period":3600}}'
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': server_rate_limits}])
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        org_rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', org_rate_limits)
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn
            service_manager = ServiceManager('geocoder', MapzenGeocoderConfigBuilder, self.username, self.orgname)
            self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])

    def test_legacy_user_rate_limit_precedence_over_org(self):
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        org_rate_limits = '{"limit":"1000","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', org_rate_limits)
        user_redis_name = "rails:users:{0}".format(self.username)
        user_rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(user_redis_name, 'geocoder_rate_limit', user_rate_limits)
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')
        self.redis_conn.hdel(user_redis_name, 'geocoder_rate_limit')

    def test_legacy_org_rate_limit_precedence_over_server(self):
        server_rate_limits = '{"geocoder":{"limit":"1000","period":3600}}'
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': server_rate_limits}])
        org_redis_name = "rails:orgs:{0}".format(self.orgname)
        org_rate_limits = '{"limit":"3","period":3600}'
        self.redis_conn.hset(org_redis_name, 'geocoder_rate_limit', org_rate_limits)
        config = GeocoderConfig(self.redis_conn, plpy_mock, self.username, self.orgname,  'mapzen')
        config_cache = {
          'redis_connection_test_user' : { 'redis_metrics_connection': self.redis_conn },
          'user_geocoder_config_test_user' : config,
          'logger_config' : Mock(min_log_level='debug', log_file_path=None, rollbar_api_key=None, environment=self.environment)
        }
        service_manager = LegacyServiceManager('geocoder', self.username, self.orgname, config_cache)
        self.check_rate_limit(service_manager, 3)
        self.redis_conn.hdel(org_redis_name, 'geocoder_rate_limit')
        plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])

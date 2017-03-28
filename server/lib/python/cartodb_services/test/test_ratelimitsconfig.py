from test_helper import *
from unittest import TestCase
from mock import Mock, MagicMock, patch
from nose.tools import assert_raises, assert_not_equal, assert_equal

from datetime import datetime, date
from mockredis import MockRedis
import cartodb_services

from cartodb_services.tools import ServiceManager, LegacyServiceManager

from cartodb_services.metrics import GeocoderConfig
from cartodb_services.refactor.service.mapzen_geocoder_config import MapzenGeocoderConfigBuilder
from cartodb_services.refactor.backend.redis_metrics_connection import RedisConnectionBuilder
from cartodb_services.tools import RateLimitExceeded

from cartodb_services.refactor.storage.redis_config import *
from cartodb_services.refactor.storage.mem_config import InMemoryConfigStorage
from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
from cartodb_services.config import RateLimitsConfig, RateLimitsConfigBuilder, RateLimitsConfigSetter

class TestRateLimitsConfig(TestCase):

    def setUp(self):
        plpy_mock_config()
        cartodb_services.init(plpy_mock, _GD={})
        self.username = 'test_user'
        self.orgname = 'test_org'
        self.redis_conn = MockRedis()
        build_redis_user_config(self.redis_conn, self.username, 'geocoding')
        build_redis_org_config(self.redis_conn, self.orgname, 'geocoding', provider='mapzen')
        self.environment = 'production'
        plpy_mock._define_result("CDB_Conf_GetConf\('server_conf'\)", [{'conf': '{"environment": "production"}'}])
        plpy_mock._define_result("CDB_Conf_GetConf\('redis_metadata_config'\)", [{'conf': '{"redis_host":"localhost","redis_port":"6379"}'}])
        plpy_mock._define_result("CDB_Conf_GetConf\('redis_metrics_config'\)", [{'conf': '{"redis_host":"localhost","redis_port":"6379"}'}])
        basic_server_conf = {"server_conf": {"environment": "testing"},
                                                     "mapzen_conf":
                                                     {"geocoder":
                                                      {"api_key": "search-xxxxxxx", "monthly_quota": 1500000, "service":{"base_url":"http://base"}}
                                                     }, "logger_conf": {}}
        self.empty_server_config = InMemoryConfigStorage(basic_server_conf)
        self.empty_redis_config = InMemoryConfigStorage({})
        self.user_config = RedisUserConfigStorageBuilder(self.redis_conn, self.username).get()
        self.org_config = RedisOrgConfigStorageBuilder(self.redis_conn, self.orgname).get()
        self.server_config = ServerConfigBackendFactory().get()

    def test_server_config(self):
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn

            # Write server level configuration
            config = RateLimitsConfig(service='geocoder', username=self.username, limit=1234, period=86400)
            config_setter = RateLimitsConfigSetter(service='geocoder', username=self.username, orgname=self.orgname)
            plpy_mock._start_logging_executed_queries()
            config_setter.set_server_rate_limits(config)
            assert plpy_mock._has_executed_query('cdb_conf_setconf(\'rate_limits\', \'{"geocoder": {"limit": 1234, "period": 86400}}\')')

            # Re-read configuration
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': '{"geocoder": {"limit": 1234, "period": 86400}}'}])
            read_config = RateLimitsConfigBuilder(
                server_conf=self.server_config,
                user_conf=self.empty_redis_config,
                org_conf=self.empty_redis_config,
                service='geocoder',
                username=self.username,
                orgname=self.orgname
            ).get()
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])
            assert_equal(read_config, config)

    def test_server_org_config(self):
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn

            server_config = RateLimitsConfig(service='geocoder', username=self.username, limit=1234, period=86400)
            org_config = RateLimitsConfig(service='geocoder', username=self.username, limit=1235, period=86400)
            config_setter = RateLimitsConfigSetter(service='geocoder', username=self.username, orgname=self.orgname)

            # Write server level configuration
            config_setter.set_server_rate_limits(server_config)
            # Override with org level configuration
            config_setter.set_org_rate_limits(org_config)

            # Re-read configuration
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': '{"geocoder": {"limit": 1234, "period": 86400}}'}])
            read_config = RateLimitsConfigBuilder(
                server_conf=self.server_config,
                user_conf=self.empty_redis_config,
                org_conf=self.org_config,
                service='geocoder',
                username=self.username,
                orgname=self.orgname
            ).get()
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])
            assert_equal(read_config, org_config)

    def test_server_org_user_config(self):
        with patch.object(RedisConnectionBuilder,'get') as get_fn:
            get_fn.return_value = self.redis_conn

            server_config = RateLimitsConfig(service='geocoder', username=self.username, limit=1234, period=86400)
            org_config = RateLimitsConfig(service='geocoder', username=self.username, limit=1235, period=86400)
            user_config = RateLimitsConfig(service='geocoder', username=self.username, limit=1236, period=86400)
            config_setter = RateLimitsConfigSetter(service='geocoder', username=self.username, orgname=self.orgname)

            # Write server level configuration
            config_setter.set_server_rate_limits(server_config)
            # Override with org level configuration
            config_setter.set_org_rate_limits(org_config)
            # Override with user level configuration
            config_setter.set_user_rate_limits(user_config)

            # Re-read configuration
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [{'conf': '{"geocoder": {"limit": 1234, "period": 86400}}'}])
            read_config = RateLimitsConfigBuilder(
                server_conf=self.server_config,
                user_conf=self.user_config,
                org_conf=self.org_config,
                service='geocoder',
                username=self.username,
                orgname=self.orgname
            ).get()
            plpy_mock._define_result("CDB_Conf_GetConf\('rate_limits'\)", [])
            assert_equal(read_config, user_config)

from unittest import TestCase
from mockredis import MockRedis
from datetime import datetime
from cartodb_services.refactor.service.mapzen_geocoder_config import *
from cartodb_services.refactor.storage.redis_config import *
from cartodb_services.refactor.storage.mem_config import InMemoryConfigStorage


class TestMapzenGeocoderUserConfig(TestCase):

    def setUp(self):
        self._redis_connection = MockRedis()
        self._server_config = InMemoryConfigStorage({"server_conf": {"environment": "testing"},
                                                     "mapzen_conf":
                                                     {"geocoder":
                                                      {"api_key": "search-xxxxxxx", "monthly_quota": 1500000, "service":{"base_url":"http://base"}}
                                                     }, "logger_conf": {}})
        self._username = 'test_user'
        self._user_key = "rails:users:{0}".format(self._username)
        self._user_config = RedisUserConfigStorageBuilder(self._redis_connection,
                                                    self._username).get()
        self._org_config = RedisOrgConfigStorageBuilder(self._redis_connection,
                                                  None).get()
        self._set_default_config_values()

    def test_config_values_are_ok(self):
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.geocoding_quota == 100
        assert config.soft_geocoding_limit == False
        assert config.period_end_date == datetime.strptime('2016-12-31 00:00:00', "%Y-%m-%d %H:%M:%S")
        assert config.service_type == 'geocoder_mapzen'
        assert config.provider == 'mapzen'
        assert config.is_high_resolution == True
        assert config.cost_per_hit == 0
        assert config.mapzen_api_key == 'search-xxxxxxx'
        assert config.username == 'test_user'
        assert config.organization is None

    def test_quota_should_be_0_if_redis_value_is_0(self):
        self._redis_connection.hset(self._user_key, 'geocoding_quota', '0')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.geocoding_quota == 0

    def test_quota_should_be_0_if_redis_value_is_empty_string(self):
        self._redis_connection.hset(self._user_key, 'geocoding_quota', '')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.geocoding_quota == 0

    def test_soft_limit_should_be_true(self):
        self._redis_connection.hset(self._user_key, 'soft_geocoding_limit', 'true')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.soft_geocoding_limit == True

    def test_soft_limit_should_be_false_if_is_empty_string(self):
        self._redis_connection.hset(self._user_key, 'soft_geocoding_limit', '')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.soft_geocoding_limit == False

    def _set_default_config_values(self):
        self._redis_connection.hset(self._user_key, 'geocoding_quota', '100')
        self._redis_connection.hset(self._user_key, 'soft_geocoding_limit', 'false')
        self._redis_connection.hset(self._user_key, 'period_end_date', '2016-12-31 00:00:00')

    def test_config_service_values(self):
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             None).get()
        assert config.service_params == {"base_url":"http://base"}

class TestMapzenGeocoderOrgConfig(TestCase):

    def setUp(self):
        self._redis_connection = MockRedis()
        self._server_config = InMemoryConfigStorage({"server_conf": {"environment": "testing"},
                                                     "mapzen_conf":
                                                     {"geocoder":
                                                      {"api_key": "search-xxxxxxx", "monthly_quota": 1500000}
                                                     }, "logger_conf": {}})
        self._username = 'test_user'
        self._organization = 'test_org'
        self._user_key = "rails:users:{0}".format(self._username)
        self._org_key = "rails:orgs:{0}".format(self._organization)
        self._user_config = RedisUserConfigStorageBuilder(self._redis_connection,
                                                    self._username).get()
        self._org_config = RedisOrgConfigStorageBuilder(self._redis_connection,
                                                  self._organization).get()
        self._set_default_config_values()


    def test_config_org_values_are_ok(self):
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             self._organization).get()
        assert config.geocoding_quota == 200
        assert config.soft_geocoding_limit == False
        assert config.period_end_date == datetime.strptime('2016-12-31 00:00:00', "%Y-%m-%d %H:%M:%S")
        assert config.service_type == 'geocoder_mapzen'
        assert config.provider == 'mapzen'
        assert config.is_high_resolution == True
        assert config.cost_per_hit == 0
        assert config.mapzen_api_key == 'search-xxxxxxx'
        assert config.username == 'test_user'
        assert config.organization is 'test_org'

    def test_quota_should_be_0_if_redis_value_is_0(self):
        self._redis_connection.hset(self._org_key, 'geocoding_quota', '0')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             self._organization).get()
        assert config.geocoding_quota == 0

    def test_quota_should_use_user_quota_value_if_redis_value_is_empty_string(self):
        self._redis_connection.hset(self._org_key, 'geocoding_quota', '')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             self._organization).get()
        assert config.geocoding_quota == 100

    def test_quota_should_be_0_if_both_user_and_org_have_empty_string(self):
        self._redis_connection.hset(self._user_key, 'geocoding_quota', '')
        self._redis_connection.hset(self._org_key, 'geocoding_quota', '')
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             self._organization).get()
        assert config.geocoding_quota == 0

    def _set_default_config_values(self):
        self._redis_connection.hset(self._user_key, 'geocoding_quota', '100')
        self._redis_connection.hset(self._user_key, 'soft_geocoding_limit', 'false')
        self._redis_connection.hset(self._user_key, 'period_end_date', '2016-12-15 00:00:00')
        self._redis_connection.hset(self._org_key, 'geocoding_quota', '200')
        self._redis_connection.hset(self._org_key, 'period_end_date', '2016-12-31 00:00:00')

    def test_config_default_service_values(self):
        config = MapzenGeocoderConfigBuilder(self._server_config,
                                             self._user_config,
                                             self._org_config,
                                             self._username,
                                             self._organization).get()
        assert config.service_params == {}

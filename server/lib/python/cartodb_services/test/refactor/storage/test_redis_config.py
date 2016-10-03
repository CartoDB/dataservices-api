from unittest import TestCase
from cartodb_services.refactor.storage.redis_config import *
from cartodb_services.refactor.storage.mem_config import InMemoryConfigStorage
from cartodb_services.refactor.config.exceptions import ConfigException

class TestRedisConnectionConfig(TestCase):

    def test_config_holds_values(self):
        # this is mostly for completeness, dummy class, dummy test
        config = RedisConnectionConfig('myhost.com', 6379, 0.1, 5, None)
        assert config.host == 'myhost.com'
        assert config.port == 6379
        assert config.timeout == 0.1
        assert config.db == 5
        assert config.sentinel_id is None


class TestRedisConnectionConfigBuilder(TestCase):

    def test_it_raises_exception_as_it_is_abstract(self):
        server_config_storage = InMemoryConfigStorage()
        self.assertRaises(TypeError, RedisConnectionConfigBuilder, server_config_storage, 'whatever_key')


class TestRedisMetadataConnectionConfigBuilder(TestCase):

    def test_it_raises_exception_if_config_is_missing(self):
        server_config_storage = InMemoryConfigStorage()
        config_builder = RedisMetadataConnectionConfigBuilder(server_config_storage)
        self.assertRaises(ConfigException, config_builder.get)

    def test_it_gets_a_valid_config_from_the_server_storage(self):
        server_config_storage = InMemoryConfigStorage({
            'redis_metadata_config': {
                'redis_host': 'myhost.com',
                'redis_port': 6379,
                'timeout': 0.2,
                'redis_db': 3,
                'sentinel_master_id': None
            }
        })
        config = RedisMetadataConnectionConfigBuilder(server_config_storage).get()
        assert config.host == 'myhost.com'
        assert config.port == 6379
        assert config.timeout == 0.2
        assert config.db == 3
        assert config.sentinel_id is None

    def test_it_gets_a_default_timeout_if_none(self):
        server_config_storage = InMemoryConfigStorage({
            'redis_metadata_config': {
                'redis_host': 'myhost.com',
                'redis_port': 6379,
                'timeout': None,
                'redis_db': 3,
                'sentinel_master_id': None
            }
        })
        config = RedisMetadataConnectionConfigBuilder(server_config_storage).get()
        assert config.host == 'myhost.com'
        assert config.port == 6379
        assert config.timeout == RedisConnectionConfigBuilder.DEFAULT_TIMEOUT
        assert config.db == 3
        assert config.sentinel_id is None

    def test_it_gets_a_default_db_if_none(self):
        server_config_storage = InMemoryConfigStorage({
            'redis_metadata_config': {
                'redis_host': 'myhost.com',
                'redis_port': 6379,
                'timeout': 0.2,
                'redis_db': None,
                'sentinel_master_id': None
            }
        })
        config = RedisMetadataConnectionConfigBuilder(server_config_storage).get()
        assert config.host == 'myhost.com'
        assert config.port == 6379
        assert config.timeout == 0.2
        assert config.db == RedisConnectionConfigBuilder.DEFAULT_USER_DB
        assert config.sentinel_id is None


class TestRedisMetricsConnectionConfigBuilder(TestCase):

    def test_it_gets_a_valid_config_from_the_server_storage(self):
        server_config_storage = InMemoryConfigStorage({
            'redis_metrics_config': {
                'redis_host': 'myhost.com',
                'redis_port': 6379,
                'timeout': 0.2,
                'redis_db': 3,
                'sentinel_master_id': 'some_master_id'
            }
        })
        config = RedisMetricsConnectionConfigBuilder(server_config_storage).get()
        assert config.host == 'myhost.com'
        assert config.port == 6379
        assert config.timeout == 0.2
        assert config.db == 3
        assert config.sentinel_id == 'some_master_id'

from unittest import TestCase
from cartodb_services.refactor.storage.redis_config import *
from mockredis import MockRedis
from mock import Mock, MagicMock
from nose.tools import raises


class TestRedisConfigStorage(TestCase):

    CONFIG_HASH_KEY = 'mykey'

    def test_can_get_a_config_field(self):
        connection = MockRedis()
        connection.hset(self.CONFIG_HASH_KEY, 'field1', 42)
        redis_config = RedisConfigStorage(connection, self.CONFIG_HASH_KEY)

        value = redis_config.get('field1')
        assert type(value) == str # this is something to take into account, redis always returns strings
        assert value == '42'

    @raises(KeyError)
    def test_raises_an_exception_if_config_key_not_present(self):
        connection = MockRedis()
        redis_config = RedisConfigStorage(connection, self.CONFIG_HASH_KEY)
        redis_config.get('whatever_field')

    @raises(KeyError)
    def test_returns_nothing_if_field_not_present(self):
        connection = MockRedis()
        connection.hmset(self.CONFIG_HASH_KEY, {'field1': 42, 'field2': 43})
        redis_config = RedisConfigStorage(connection, self.CONFIG_HASH_KEY)
        redis_config.get('whatever_field')

    def test_it_reads_the_config_hash_just_once(self):
        connection = Mock()
        connection.hgetall = MagicMock(return_value={'field1': '42'})
        redis_config = RedisConfigStorage(connection, self.CONFIG_HASH_KEY)

        assert redis_config.get('field1') == '42'
        assert redis_config.get('field1') == '42'

        connection.hgetall.assert_called_once_with(self.CONFIG_HASH_KEY)


class TestRedisUserConfigStorageBuilder(TestCase):

    USERNAME = 'john'
    EXPECTED_REDIS_CONFIG_HASH_KEY = 'rails:users:john'
    
    def test_it_reads_the_correct_hash_key(self):
        connection = Mock()
        connection.hgetall = MagicMock(return_value={'an_user_config_field': 'nice'})
        redis_config = RedisConfigStorage(connection, self.EXPECTED_REDIS_CONFIG_HASH_KEY)

        redis_config = RedisUserConfigStorageBuilder(connection, self.USERNAME).get()
        assert redis_config.get('an_user_config_field') == 'nice'
        connection.hgetall.assert_called_once_with(self.EXPECTED_REDIS_CONFIG_HASH_KEY)


class TestRedisOrgConfigStorageBuilder(TestCase):

    ORGNAME = 'smith'
    EXPECTED_REDIS_CONFIG_HASH_KEY = 'rails:orgs:smith'

    def test_it_reads_the_correct_hash_key(self):
        connection = Mock()
        connection.hgetall = MagicMock(return_value={'an_org_config_field': 'awesome'})
        redis_config = RedisConfigStorage(connection, self.EXPECTED_REDIS_CONFIG_HASH_KEY)

        redis_config = RedisOrgConfigStorageBuilder(connection, self.ORGNAME).get()
        assert redis_config.get('an_org_config_field') == 'awesome'
        connection.hgetall.assert_called_once_with(self.EXPECTED_REDIS_CONFIG_HASH_KEY)

    def test_it_returns_a_null_config_storage_if_theres_no_orgname(self):
        redis_config = RedisOrgConfigStorageBuilder(None, None).get()
        assert type(redis_config) == NullConfigStorage
        assert redis_config.get('whatever') == None

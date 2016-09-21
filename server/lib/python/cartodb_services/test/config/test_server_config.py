from unittest import TestCase
from mock import Mock, MagicMock
from nose.tools import raises
from cartodb_services.config.server_config import *
from cartodb_services.config.interfaces import ConfigStorageInterface
import cartodb_services

class TestServerConfigFactory(TestCase):

    def tearDown(self):
        ServerConfigFactory._reset()

    def test_instantiates_a_config_storage(self):
        cs = ServerConfigFactory.get()
        assert isinstance(cs, ConfigStorageInterface)

    def test_returns_by_default_an_in_db_config_storage(self):
        cs = ServerConfigFactory.get()
        assert isinstance(cs, InDbServerConfigStorage)

    def test_can_be_set_to_return_other_storages(self):
        my_storage = InMemoryConfigStorage()
        ServerConfigFactory._set(my_storage)
        cs = ServerConfigFactory.get()
        assert cs == my_storage


class TestInDbServerConfigStorage(TestCase):

    def setUp(self):
        self.plpy_mock = Mock()
        cartodb_services.init(self.plpy_mock, _GD={})

    def tearDown(self):
        cartodb_services._reset()

    def test_gets_configs_from_db(self):
        self.plpy_mock.execute = MagicMock(return_value=[{'conf': '"any_value"'}])
        server_config = ServerConfigFactory.get()
        assert server_config.get('any_config') == 'any_value'
        self.plpy_mock.execute.assert_called_once_with("SELECT cdb_dataservices_server.cdb_conf_getconf('any_config') as conf", 1)

    @raises(ConfigException)
    def test_raises_exception_if_cannot_retrieve_key(self):
        self.plpy_mock.execute = MagicMock(return_value=None)
        server_config = ServerConfigFactory.get()
        server_config.get('any_config')

    def test_deserializes_from_db_to_plain_dict(self):
        self.plpy_mock.execute = MagicMock(return_value=[{'conf': '{"environment": "testing"}'}])
        server_config = ServerConfigFactory.get()
        assert server_config.get('server_conf') == {'environment': 'testing'}
        self.plpy_mock.execute.assert_called_once_with("SELECT cdb_dataservices_server.cdb_conf_getconf('server_conf') as conf", 1)


class TestInMemoryConfigStorage(TestCase):

    def test_can_provide_values_from_hash(self):
        server_config = InMemoryConfigStorage({'any_key': 'any_value'})
        assert server_config.get('any_key') == 'any_value'

    @raises(ConfigException)
    def test_raises_exception_if_cannot_retrieve_key(self):
        server_config = InMemoryConfigStorage()
        server_config.get('any_key')

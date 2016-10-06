from unittest import TestCase
from mock import Mock, MagicMock
from nose.tools import raises
from cartodb_services.refactor.storage.server_config import *
import cartodb_services

class TestInDbServerConfigStorage(TestCase):

    def setUp(self):
        self.plpy_mock = Mock()
        cartodb_services.init(self.plpy_mock, _GD={})

    def tearDown(self):
        cartodb_services._reset()

    def test_gets_configs_from_db(self):
        self.plpy_mock.execute = MagicMock(return_value=[{'conf': '"any_value"'}])
        server_config = InDbServerConfigStorage()
        assert server_config.get('any_config') == 'any_value'
        self.plpy_mock.execute.assert_called_once_with("SELECT cdb_dataservices_server.cdb_conf_getconf('any_config') as conf", 1)

    def test_gets_none_if_cannot_retrieve_key(self):
        self.plpy_mock.execute = MagicMock(return_value=[{'conf': None}])
        server_config = InDbServerConfigStorage()
        assert server_config.get('any_non_existing_key') is None

    def test_deserializes_from_db_to_plain_dict(self):
        self.plpy_mock.execute = MagicMock(return_value=[{'conf': '{"environment": "testing"}'}])
        server_config = InDbServerConfigStorage()
        assert server_config.get('server_conf') == {'environment': 'testing'}
        self.plpy_mock.execute.assert_called_once_with("SELECT cdb_dataservices_server.cdb_conf_getconf('server_conf') as conf", 1)

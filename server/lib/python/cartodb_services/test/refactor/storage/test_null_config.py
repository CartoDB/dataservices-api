from unittest import TestCase
from cartodb_services.refactor.storage.null_config import NullConfigStorage
from cartodb_services.refactor.core.interfaces import ConfigBackendInterface


class TestNullConfigStorage(TestCase):

    def test_is_a_config_backend(self):
        null_config = NullConfigStorage()
        assert isinstance(null_config, ConfigBackendInterface)

    def test_returns_none_regardless_of_input(self):
        null_config = NullConfigStorage()
        assert null_config.get('whatever') is None

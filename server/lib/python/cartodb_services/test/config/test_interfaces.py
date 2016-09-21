from unittest import TestCase
from cartodb_services.config.interfaces import ConfigStorageInterface
from nose.tools import raises

class TestConfigStorageInterface(TestCase):

    @raises(TypeError)
    def test_cannot_instantiate_interface(self):
        c = ConfigStorageInterface()

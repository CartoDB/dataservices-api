from unittest import TestCase
from cartodb_services.refactor.storage.mem_config import InMemoryConfigStorage

class TestInMemoryConfigStorage(TestCase):

    def test_can_provide_values_from_hash(self):
        server_config = InMemoryConfigStorage({'any_key': 'any_value'})
        assert server_config.get('any_key') == 'any_value'

    def test_gets_none_if_cannot_retrieve_key(self):
        server_config = InMemoryConfigStorage()
        assert server_config.get('any_non_existing_key') == None

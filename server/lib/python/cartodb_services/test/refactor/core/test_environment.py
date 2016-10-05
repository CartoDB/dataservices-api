from unittest import TestCase
from cartodb_services.refactor.core.environment import *
from nose.tools import raises
from cartodb_services.refactor.storage.mem_config import InMemoryConfigStorage

class TestServerEnvironment(TestCase):

    def test_can_be_a_valid_one(self):
        env_dev = ServerEnvironment('development')
        env_staging = ServerEnvironment('staging')
        env_prod = ServerEnvironment('production')
        env_onpremise = ServerEnvironment('onpremise')

    @raises(AssertionError)
    def test_cannot_be_a_non_valid_one(self):
        env_whatever = ServerEnvironment('whatever')

    def test_is_on_premise_returns_true_when_onpremise(self):
        assert ServerEnvironment('onpremise').is_onpremise == True

    def test_is_on_premise_returns_true_when_any_other(self):
        assert ServerEnvironment('development').is_onpremise == False
        assert ServerEnvironment('staging').is_onpremise == False
        assert ServerEnvironment('production').is_onpremise == False

    def test_equality(self):
        assert ServerEnvironment('development') == ServerEnvironment('development')
        assert ServerEnvironment('development') <> ServerEnvironment('onpremise')


class TestServerEnvironmentBuilder(TestCase):

    def test_returns_env_according_to_configuration(self):
        server_config_storage = InMemoryConfigStorage({
            'server_conf': {
                'environment': 'staging'
            }
        })
        server_env = ServerEnvironmentBuilder(server_config_storage).get()
        assert server_env.is_staging == True

    def test_returns_default_when_no_server_conf(self):
        server_config_storage = InMemoryConfigStorage({})
        server_env = ServerEnvironmentBuilder(server_config_storage).get()

        assert server_env.is_development == True
        assert str(server_env) == ServerEnvironmentBuilder.DEFAULT_ENVIRONMENT

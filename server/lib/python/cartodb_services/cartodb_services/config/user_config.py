import cartodb_services
from exceptions import ConfigException
from environment import Environment
from cartodb_services.config.interfaces import ConfigStorageInterface
from cartodb_services.config.server_config import InDbServerConfigStorage
from cartodb_services.tools.redis_tools import RedisConnectionFactory


class UserConfigFactory(object):

    _user_config_obj = None

    @classmethod
    def get(cls, user):
        if cls._user_config_obj:
            return cls._user_config_obj
        else:
            environment = Environment().get()
            if environment == 'onpremise':
                user_config_obj = InDbServerConfigStorage()
            else:
                user_config_obj = RedisUserConfig(user.username)
            return user_config_obj

    @classmethod
    def _set(cls, obj):
        """To be used just for testing"""
        assert isinstance(obj, ConfigStorageInterface)
        cls._user_config_obj = obj

    @classmethod
    def _reset(cls):
        cls._user_config_obj = None


class RedisUserConfig(object):

    def __init__(self, username):
        self._username = username
        self._redis_conn = RedisConnectionFactory().get_metadata_connection(username)
        self._user_config = None

    def get(self, key):
        if not self._user_config:
            self._user_config = self._redis_conn.hgetall(
                "rails:users:{0}".format(self._username)
            )
        try:
            return self._user_config[key]
        except KeyError:
            return None

import cartodb_services
from exceptions import ConfigException
from environment import Environment
from cartodb_services.config.interfaces import ConfigStorageInterface
from cartodb_services.config.server_config import InDbServerConfigStorage


class UserConfigFactory(object):

    _user_config_obj = None

    @classmethod
    def get(cls, user):
        if cls._user_config_obj:
            # In-memory cache
            return cls._user_config_obj
        else:
            environment = Environment().get()
            if environment == 'onpremise':
                cls._user_config_obj = InDbServerConfigStorage()
            else:
                cls._user_config_obj = RedisUserConfig(user.username)
            return cls._user_config_obj

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
        self._redis_comm = RedisConnectionFactory().get_metadata_connection(username)

    def get(self, key):
        return self._redis_conn.hget(
            "rails:users:{0} {1}".format(self._username, key)
            )

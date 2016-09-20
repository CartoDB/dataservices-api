import cartodb_services
from exceptions import ConfigException
from config import Environment

class UserConfigFactory(Object, username, orgname = None):

    def __init__(self):
        self._username = username
        self._orgname = orgname
        self._environment = Environment().get()
        self._user_config_obj = None

    def get(self):
        if self._user_config_obj:
            return self._user_config_obj
        elif self._environment is 'onpremises':
            # Asuming there's no separate organization settings
            # because it is all set in server DB
            return DbUserConfig()
        elif self._orgname is not None:
            return RedisOrgConfig(orgname)
        else:
            return RedisUserConfig(username)

    def _set(self, obj):
        """To be used just for testing"""
        self._user_config_obj = obj

    def _reset(self):
        self._user_config_obj = None

class DbUserConfig(Object):

    def __init__(self):
        self._db_conn = DbConf()

    def get(self, key):
        return self._db_conn.get(key) # This should be an abstraction of DBServerConfig.get()

class RedisUserConfig(Object):

    def __init__(self, username):
        self._redis_conn = RedisConnectionFactory().get_metadata_connection(username)

    def get(self, key):
        pass

class RedisOrgConfig(Object):

    def __init__(self, orgname):
        self._redis_conn = RedisConnectionFactory().get_metadata_connection(orgname)

    def get(self, key):
        pass

class DummyUserConfig(Object):
   def __init__(self, config_hash):
        self._config_hash = config_hash

    def get(self, key):
        try:
            return self._config_hash[key]
        except Exception as e:
            raise ConfigException("Key {0} not found for UserConfig: {1}".format(key, e))

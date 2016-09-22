import cartodb_services
import json
from exceptions import ConfigException
from cartodb_services.config.interfaces import ConfigStorageInterface

class ServerConfigFactory:

    _server_config_obj = None

    @classmethod
    def get(cls):
        """Return a config storage"""
        if cls._server_config_obj:
            return cls._server_config_obj
        else:
            cls._server_config_obj = InDbServerConfigStorage()
            return cls._server_config_obj

    @classmethod
    def _set(cls, obj):
        """To be used just for testing"""
        assert isinstance(obj, ConfigStorageInterface)
        cls._server_config_obj = obj

    @classmethod
    def _reset(cls):
        cls._server_config_obj = None


class InDbServerConfigStorage(ConfigStorageInterface):

    # TODO: instead of raising an exception if missing it should return None
    def get(self, key):
        try:
            sql = "SELECT cdb_dataservices_server.cdb_conf_getconf('{0}') as conf".format(key)
            rows = cartodb_services.plpy.execute(sql, 1)
            return json.loads(rows[0]['conf'])
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))


class InMemoryConfigStorage(ConfigStorageInterface):

    def __init__(self, config_hash={}):
        self._config_hash = config_hash

    def get(self, key):
        try:
            return self._config_hash[key]
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))

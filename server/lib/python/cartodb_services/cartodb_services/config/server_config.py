from cartodb_services import plpy, GD
from exceptions import ConfigException

class ServerConfigFactory:

    _server_config_obj = None

    @classmethod
    def get(cls):
        if cls._server_config_obj:
            return cls._server_config_obj
        else:
            cls._server_config_obj = DbServerConfig()
            return cls._server_config_obj

    @classmethod
    def _set(cls, obj):
        """To be used just for testing"""
        cls._server_config_obj = obj

    @classmethod
    def _reset(cls):
        cls._server_config_obj = None


class DbServerConfig:

    def get(self, key):
        try:
            sql = "SELECT cdb_dataservices_server.cdb_conf_getconf('{0}') as conf".format(key)
            conf = plpy.execute(sql, 1)
            return conf[0]['conf']
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))


class DummyServerConfig:

    def __init__(self, config_hash):
        self._config_hash = config_hash

    def get(self, key):
        try:
            return self._config_hash[key]
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))

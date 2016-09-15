from exceptions import *

class DBConfig:
    def __init__(self, plpy):
        self._plpy = plpy

    def get(self, key):
        try:
            sql = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(key)
            conf = self._plpy.execute(sql, 1)
            return conf[0]['conf']
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))

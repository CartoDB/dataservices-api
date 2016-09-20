from exceptions import *
import plpy

class DBConfig:

    def get(self, key):
        try:
            sql = "SELECT cdb_dataservices_server.cdb_conf_getconf('{0}') as conf".format(key)
            conf = plpy.execute(sql, 1)
            return conf[0]['conf']
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))

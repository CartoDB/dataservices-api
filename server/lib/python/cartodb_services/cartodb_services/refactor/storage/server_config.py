import json
import cartodb_services
from interfaces import ConfigStorageInterface

class InDbServerConfigStorage(ConfigStorageInterface):

    def get(self, key):
        sql = "SELECT cdb_dataservices_server.cdb_conf_getconf('{0}') as conf".format(key)
        rows = cartodb_services.plpy.execute(sql, 1)
        json_output = rows[0]['conf']
        if json_output:
            return json.loads(json_output)
        else:
            return None


class InMemoryConfigStorage(ConfigStorageInterface):

    def __init__(self, config_hash={}):
        self._config_hash = config_hash

    def get(self, key):
        try:
            return self._config_hash[key]
        except KeyError:
            return None

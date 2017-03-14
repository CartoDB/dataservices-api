import json
import cartodb_services
from ..core.interfaces import ConfigBackendInterface

class InDbServerConfigStorage(ConfigBackendInterface):

    def get(self, key, default=None):
        sql = "SELECT cdb_dataservices_server.cdb_conf_getconf('{0}') as conf".format(key)
        rows = cartodb_services.plpy.execute(sql, 1)
        json_output = None
        try:
            json_output = rows[0]['conf']
        except IndexError:
            pass
        if (json_output):
            return json.loads(json_output)
        else:
            if (default == KeyError):
                raise KeyError
            else:
                return default

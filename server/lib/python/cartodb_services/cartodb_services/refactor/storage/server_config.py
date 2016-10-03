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

class NullConfigStorage(ConfigStorageInterface):

    def get(self, key):
        return None

# TODO move out of this file. In general this is config but either user or org config
class RedisConfigStorage(ConfigStorageInterface):

    def __init__(self, connection, config_key):
        self._connection = connection
        self._config_key = config_key
        self._data = None

    def get(self, key):
        if not self._data:
            self._data = self._connection.hgetall(self._config_key)
        return self._data[key]

class UserConfigStorageFactory(object):
    # TODO rework to support onpremise and InDbStorage
    def __init__(self, redis_connection, username):
        self._redis_connection = redis_connection
        self._username = username

    def get(self):
        return RedisConfigStorage(self._redis_connection, 'rails:users:{0}'.format(self._username))

class OrgConfigStorageFactory(object):
    # TODO rework to support onpremise and InDbStorage
    def __init__(self, redis_connection, orgname):
        self._redis_connection = redis_connection
        self._orgname = orgname

    def get(self):
        if self._orgname:
            return RedisConfigStorage(self._redis_connection, 'rails:orgs:{0}'.format(self._orgname))
        else:
            return NullConfigStorage()

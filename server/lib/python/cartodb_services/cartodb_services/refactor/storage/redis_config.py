from ..core.interfaces import ConfigBackendInterface
from null_config import NullConfigStorage


class RedisConfigStorage(ConfigBackendInterface):

    def __init__(self, connection, config_key):
        self._connection = connection
        self._config_key = config_key
        self._data = None

    def get(self, key, default=KeyError):
        if not self._data:
            self._data = self._connection.hgetall(self._config_key)
        if (default == KeyError):
            return self._data[key]
        else:
            return self._data.get(key, default)

   def set(self, key, value):
        self._connection.hset(self._config_key, key, value)

   def remove(self, key):
        self._connection.hdel(self._config_key, key)

class RedisUserConfigStorageBuilder(object):
    def __init__(self, redis_connection, username):
        self._redis_connection = redis_connection
        self._username = username

    def get(self):
        return RedisConfigStorage(self._redis_connection, 'rails:users:{0}'.format(self._username))


class RedisOrgConfigStorageBuilder(object):
    def __init__(self, redis_connection, orgname):
        self._redis_connection = redis_connection
        self._orgname = orgname

    def get(self):
        if self._orgname:
            return RedisConfigStorage(self._redis_connection, 'rails:orgs:{0}'.format(self._orgname))
        else:
            return NullConfigStorage()

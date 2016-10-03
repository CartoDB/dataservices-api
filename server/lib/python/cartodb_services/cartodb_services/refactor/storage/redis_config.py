from interfaces import ConfigStorageInterface
from null_config import NullConfigStorage


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

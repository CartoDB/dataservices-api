from environment import Environment
from interfaces import ConfigStorageInterface
from server_config import InDbServerConfigStorage


class OrgConfigFactory(object):

    _org_config_obj = None

    @classmethod
    def get(cls, user):
        if cls._org_config_obj:
            # In-memory cache
            return cls._org_config_obj
        else:
            environment = Environment().get()
            if environment == 'onpremise':
                cls._org_config_obj = InDbServerConfigStorage()
            else:
                cls._org_config_obj = RedisOrgConfig(user.orgname)
            return cls._org_config_obj

    @classmethod
    def _set(cls, obj):
        """To be used just for testing"""
        cls._org_config_obj = obj

    @classmethod
    def _reset(cls):
        cls._org_config_obj = None


class RedisOrgConfig(object):

    def __init__(self, orgname):
        self._orgname = orgname
        self._redis_conn = RedisConnectionFactory().get_metadata_connection(orgname)

    def get(self, key):
        return self._redis_conn.hget(
            "rails:orgs:{0} {1}".format(self._orgname, key)
            )

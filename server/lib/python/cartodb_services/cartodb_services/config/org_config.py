from environment import Environment
from interfaces import ConfigStorageInterface
from server_config import InDbServerConfigStorage
from cartodb_services.tools.redis_tools import RedisConnectionFactory


class OrgConfigFactory(object):

    _org_config_obj = None

    @classmethod
    def get(cls, user):
        if cls._org_config_obj:
            return cls._org_config_obj
        else:
            environment = Environment().get()
            if environment == 'onpremise':
                org_config_obj = InDbServerConfigStorage()
            else:
                org_config_obj = RedisOrgConfig(user.orgname)
            return org_config_obj

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
        self._org_config = None

    def get(self, key):
        if not self._org_config:
            self._org_config = self._redis_conn.hgetall(
                "rails:orgs:{0}".format(self._orgname)
            )
        try:
            return self._org_config[key]
        except KeyError:
            return None

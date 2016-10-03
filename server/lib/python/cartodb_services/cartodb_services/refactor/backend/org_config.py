from cartodb_services.refactor.storage.redis_connection_config import RedisMetadataConnectionConfigBuilder
from cartodb_services.refactor.storage.redis_connection import RedisConnectionBuilder
from cartodb_services.refactor.storage.redis_config import RedisOrgConfigStorageBuilder

class OrgConfigBackendFactory(object):
    """
    This class abstracts the creation of an org configuration storage. It will return
    an implementation of the ConfigBackendInterface appropriate to the org, depending
    on the environment.
    """

    def __init__(self, orgname, environment, server_config_storage):
        self._orgname = orgname
        self._environment = environment
        self._server_config_storage = server_config_storage

    def get(self):
        if self._environment.is_onpremise:
            org_config_backend = self._server_config_storage
        else:
            redis_metadata_connection_config = RedisMetadataConnectionConfigBuilder(self._server_config_storage).get()
            redis_metadata_connection = RedisConnectionBuilder(redis_metadata_connection_config).get()
            org_config_backend = RedisOrgConfigStorageBuilder(redis_metadata_connection, self._orgname).get()
        return org_config_backend

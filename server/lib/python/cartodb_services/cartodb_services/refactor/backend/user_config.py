from cartodb_services.refactor.storage.redis_connection_config import RedisMetadataConnectionConfigBuilder
from cartodb_services.refactor.storage.redis_connection import RedisConnectionBuilder
from cartodb_services.refactor.storage.redis_config import RedisUserConfigStorageBuilder

class UserConfigBackendFactory(object):
    """
    This class abstracts the creation of a user configuration backend. It will return
    an implementation of the ConfigBackendInterface appropriate to the user, depending
    on the environment.
    """

    def __init__(self, username, environment, server_config_backend):
        self._username = username
        self._environment = environment
        self._server_config_backend = server_config_backend

    def get(self):
        if self._environment.is_onpremise:
            user_config_backend = self._server_config_backend
        else:
            redis_metadata_connection_config = RedisMetadataConnectionConfigBuilder(self._server_config_backend).get()
            redis_metadata_connection = RedisConnectionBuilder(redis_metadata_connection_config).get()
            user_config_backend = RedisUserConfigStorageBuilder(redis_metadata_connection, self._username).get()
        return user_config_backend

from cartodb_services.refactor.core.environment import ServerEnvironmentBuilder
from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
from cartodb_services.refactor.backend.user_config import UserConfigBackendFactory
from cartodb_services.refactor.backend.org_config import OrgConfigBackendFactory

class ServiceConfiguration(object):
    """
    This class instantiates configuration backend objects for all the configuration levels of a service:
    * environment
    * server
    * organization
    * user
    The configuration backends allow retrieval and modification of configuration parameters.
    """

    def __init__(self, service, username, orgname):
        self._server_config_backend = ServerConfigBackendFactory().get()
        self._environment = ServerEnvironmentBuilder(self._server_config_backend ).get()
        self._user_config_backend = UserConfigBackendFactory(username, self._environment, self._server_config_backend ).get()
        self._org_config_backend = OrgConfigBackendFactory(orgname, self._environment, self._server_config_backend ).get()

    @property
    def environment(self):
        return self._environment

    @property
    def server(self):
        return self._server_config_backend

    @property
    def user(self):
        return self._user_config_backend

    @property
    def org(self):
        return self._org_config_backend
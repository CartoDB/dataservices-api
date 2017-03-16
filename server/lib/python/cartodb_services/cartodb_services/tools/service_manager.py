from cartodb_services.metrics import QuotaService
from cartodb_services.tools import Logger
from cartodb_services.tools import RateLimiter
from cartodb_services.refactor.tools.logger import LoggerConfigBuilder
from cartodb_services.refactor.core.environment import ServerEnvironmentBuilder
from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
from cartodb_services.refactor.backend.user_config import UserConfigBackendFactory
from cartodb_services.refactor.backend.org_config import OrgConfigBackendFactory
from cartodb_services.refactor.backend.redis_metrics_connection import RedisMetricsConnectionFactory
from cartodb_services.refactor.config import RateLimitsConfigBuilder

class RateLimitExceeded(Exception):
    def __str__(self):
            return repr('Rate limit exceeded')

class ServiceManagerBase:
    """
    A Service manager collects the configuration needed to use a service,
    including thir-party services parameters.

    This abstract class serves as the base for concrete service manager classes;
    derived class must provide and initialize attributes for ``config``,
    ``quota_service``, ``logger`` and ``rate_limiter`` (which can be None
    for no limits).

    It provides an `assert_within_limits` method to check quota and rate limits
    which raises exceptions when limits are exceeded.

    It exposes properties containing:

    * ``config`` : a configuration object containing the configuration parameters for
      a given service and provider.
    * ``quota_service`` a QuotaService object to for quota accounting
    * ``logger``

    """

    def assert_within_limits(self, quota=True, rate=True):
        if rate and not self.rate_limiter.check():
            raise RateLimitExceeded()
        if quota and not self.quota_service.check_user_quota():
            raise Exception('You have reached the limit of your quota')

    @property
    def config(self):
        return self.config

    @property
    def quota_service(self):
        return self.quota_service

    @property
    def logger(self):
        return self.logger


class ServiceConfiguration:
    def __init__(self, service, username, orgname):
        self._server_config_backend = ServerConfigBackendFactory().get()
        self._environment = ServerEnvironmentBuilder(server_config_backend).get()
        self._user_config_backend = UserConfigBackendFactory(username, environment, server_config_backend).get()
        self._org_config_backend = OrgConfigBackendFactory(orgname, environment, server_config_backend).get()

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

class ServiceManager(ServiceManagerBase):
    """
    This service manager delegates the configuration parameter details,
    and the policies about configuration precedence to a configuration-builder class.
    It uses the refactored configuration classes.
    """

    def __init__(self, service, config_builder, username, orgname):
        service_config = ServerConfiguration(service, username, orgname)

        logger_config = LoggerConfigBuilder(service_config.environment, service_config.server).get()
        self.logger = Logger(logger_config)

        self.config = config_builder(service_config.server, service_config.user, service_config.org, username, orgname).get()
        rate_limit_config = RateLimitsConfigBuilder(service_config.server, service_config.user, service_config.org, service=service, user=username, org=orgname).get()

        redis_metrics_connection = RedisMetricsConnectionFactory(service_config.environment, service_config.server).get()

        self.rate_limiter = RateLimiter(rate_limit_config, redis_metrics_connection)
        self.quota_service = QuotaService(self.config, redis_metrics_connection)

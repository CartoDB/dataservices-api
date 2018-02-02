from cartodb_services.metrics import QuotaService
from cartodb_services.tools import Logger
from cartodb_services.tools import RateLimiter
from cartodb_services.tools import QuotaExceededException, RateLimitExceeded
from cartodb_services.refactor.tools.logger import LoggerConfigBuilder
from cartodb_services.refactor.backend.redis_metrics_connection import RedisMetricsConnectionFactory
from cartodb_services.config import ServiceConfiguration, RateLimitsConfigBuilder


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
            raise QuotaExceededException()

    @property
    def config(self):
        return self.config

    @property
    def quota_service(self):
        return self.quota_service

    @property
    def logger(self):
        return self.logger


class ServiceManager(ServiceManagerBase):
    """
    This service manager delegates the configuration parameter details,
    and the policies about configuration precedence to a configuration-builder class.
    It uses the refactored configuration classes.
    """

    def __init__(self, service, config_builder, username, orgname, GD=None):
        service_config = ServiceConfiguration(service, username, orgname)

        logger_config = LoggerConfigBuilder(service_config.environment, service_config.server).get()
        self.logger = Logger(logger_config)

        self.config = config_builder(service_config.server, service_config.user, service_config.org, username, orgname, GD).get()
        rate_limit_config = RateLimitsConfigBuilder(service_config.server, service_config.user, service_config.org, service=service, username=username, orgname=orgname).get()

        redis_metrics_connection = RedisMetricsConnectionFactory(service_config.environment, service_config.server).get()

        self.rate_limiter = RateLimiter(rate_limit_config, redis_metrics_connection)
        self.quota_service = QuotaService(self.config, redis_metrics_connection)

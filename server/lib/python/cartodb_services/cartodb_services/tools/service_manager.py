from exceptions import RateLimitExceeded

class ServiceManagerBase:
    def check(self):
        if not self.rate_limiter.check():
            raise RateLimitExceeded()
        if not self.quota_service.check_user_quota():
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

from cartodb_services.metrics import QuotaService
from cartodb_services.tools import Logger,LoggerConfig
from cartodb_services.tools import RateLimiter
from cartodb_services.refactor.config.rate_limits import RateLimitsConfig

class LegacyServiceManager(ServiceManagerBase):

    def __init__(self, service, username, orgname, gd):
        redis_conn = gd["redis_connection_{0}".format(username)]['redis_metrics_connection']
        self.config = gd["user_{0}_config_{1}".format(service, username)]
        logger_config = gd["logger_config"]
        self.logger = Logger(logger_config)

        rate_limits_config = RateLimitsConfig(service,
                                                username,
                                                self.config.rate_limit.get('limit'),
                                                self.config.rate_limit.get('period'))
        self.rate_limiter = RateLimiter(rate_limits_config, redis_conn)
        self.quota_service = QuotaService(self.config, redis_conn)

from cartodb_services.metrics import QuotaService
from cartodb_services.tools import Logger
from cartodb_services.tools import RateLimiter
from cartodb_services.refactor.tools.logger import LoggerConfigBuilder
from cartodb_services.refactor.core.environment import ServerEnvironmentBuilder
from cartodb_services.refactor.backend.server_config import ServerConfigBackendFactory
from cartodb_services.refactor.backend.user_config import UserConfigBackendFactory
from cartodb_services.refactor.backend.org_config import OrgConfigBackendFactory
from cartodb_services.refactor.backend.redis_metrics_connection import RedisMetricsConnectionFactory
from cartodb_services.refactor.config.rate_limits import RateLimitsConfigBuilder

class ServiceManager(ServiceManagerBase):

    def __init__(self, service, config_builder, username, orgname):
        server_config_backend = ServerConfigBackendFactory().get()
        environment = ServerEnvironmentBuilder(server_config_backend).get()
        user_config_backend = UserConfigBackendFactory(username, environment, server_config_backend).get()
        org_config_backend = OrgConfigBackendFactory(orgname, environment, server_config_backend).get()

        logger_config = LoggerConfigBuilder(environment, server_config_backend).get()
        self.logger = Logger(logger_config)

        self.config = config_builder(server_config_backend, user_config_backend, org_config_backend, username, orgname).get()
        rate_limit_config = RateLimitsConfigBuilder(server_config_backend, user_config_backend, org_config_backend, service=service, user=username, org=orgname).get()

        redis_metrics_connection = RedisMetricsConnectionFactory(environment, server_config_backend).get()

        self.rate_limiter = RateLimiter(rate_limit_config, redis_metrics_connection)
        self.quota_service = QuotaService(self.config, redis_metrics_connection)

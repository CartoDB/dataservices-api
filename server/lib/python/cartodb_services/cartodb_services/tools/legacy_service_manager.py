from cartodb_services.metrics import QuotaService
from cartodb_services.tools import Logger,LoggerConfig
from cartodb_services.tools import RateLimiter
from cartodb_services.config import RateLimitsConfigLegacyBuilder
from cartodb_services.tools.service_manager import ServiceManagerBase
import plpy

class LegacyServiceManager(ServiceManagerBase):
    """
    This service manager relies on cached configuration (in gd) stored in *legacy* configuration objects
    It's intended for use by the *legacy* configuration objects (in use prior to the configuration refactor).
    """

    def __init__(self, service, username, orgname, gd):
        redis_conn = gd["redis_connection_{0}".format(username)]['redis_metrics_connection']
        self.config = gd["user_{0}_config_{1}".format(service, username)]
        logger_config = gd["logger_config"]
        self.logger = Logger(logger_config)

        self.quota_service = QuotaService(self.config, redis_conn)

        rate_limit_config = RateLimitsConfigLegacyBuilder(redis_conn, plpy, service=service, username=username, orgname=orgname).get()
        self.rate_limiter = RateLimiter(rate_limit_config, redis_conn)

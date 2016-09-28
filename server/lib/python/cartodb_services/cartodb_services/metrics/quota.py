from user import UserMetricsService
from log import MetricsLoggerFactory
from datetime import date
from cartodb_services.tools.redis_tools import RedisConnectionFactory
import re


class QuotaService:
    """ Class to manage all the quota operation for
    the Dataservices SQL API Extension """

    def __init__(self, user_service_config):
        self._user_service_config = user_service_config
        self._user_service = UserMetricsService(self._user_service_config)
        self._quota_checker = QuotaChecker(user_service_config, self._user_service)
        self._metrics_logger = MetricsLoggerFactory.build(user_service_config)

    def check_user_quota(self):
        return self._quota_checker.check()

    def increment_success_service_use(self, amount=1):
        self._user_service.increment_service_use(
            self._user_service_config.service_type, "success_responses",
            amount=amount)
        self._log_service_process("success")

    def increment_empty_service_use(self, amount=1):
        self._user_service.increment_service_use(
            self._user_service_config.service_type, "empty_responses",
            amount=amount)
        self._log_service_process("empty")

    def increment_failed_service_use(self, amount=1):
        self._user_service.increment_service_use(
            self._user_service_config.service_type, "fail_responses",
            amount=amount)
        self._log_service_process("fail")

    def increment_total_service_use(self, amount=1):
        self._user_service.increment_service_use(
            self._user_service_config.service_type, "total_requests",
            amount=amount)

    def increment_isolines_service_use(self, amount=1):
        self._user_service.increment_service_use(
            self._user_service_config.service_type, "isolines_generated",
            amount=amount)

    def _log_service_process(self, event):
        if self._metrics_logger:
            if event is 'success' or event is 'empty':
                self._metrics_logger.log(success=True)
            elif event is 'empty':
                self._metrics_logger.log(success=False)



class QuotaChecker:

    # This requires following a convention: make quota properties named monthly_quota
    # and soft_X_limit properties named soft_limit in each config type
    # Half of the configs (routing and obs) are doing this already

    def __init__(self, user_service_config, user_metrics_service):
        self._user_service_config = user_service_config
        self._user_service = user_metrics_service

    def check(self):

        VALID_SERVICES = ['here_geocoder', 'here_isolines', 'routing_mapzen', 'mapzen_isolines',
            'obs_general', 'obs_snapshot', '...']

        # not even required because we're setting up the service_type
        if self._user_service_config.service_type not in VALID_SERVICES:
            return False

        available_quota = self._user_service_config.monthly_quota
        today = date.today()
        service_type = self._user_service_config.service_type
        used_quota = self._user_service.used_quota(service_type, today)
        soft_limit = self._user_service_config.soft_limit

        if soft_limit or (available_quota > 0 and used_quota <= available_quota):
            return True
        else:
            return False



from user import UserMetricsService
from log import LoggerFactory
from datetime import date
import re


class QuotaService:
    """ Class to manage all the quota operation for
    the Dataservices SQL API Extension """

    def __init__(self, user_service_config, redis_connection):
        self._user_service_config = user_service_config
        self._quota_checker = QuotaChecker(user_service_config,
                                           redis_connection)
        self._user_service = UserMetricsService(self._user_service_config,
                                                redis_connection)
        self._logger = LoggerFactory.build(user_service_config)

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
        if self._logger:
            if event is 'success' or event is 'empty':
                self._logger.log(success=True)
            elif event is 'empty':
                self._logger.log(success=False)


class QuotaChecker:

    def __init__(self, user_service_config, redis_connection):
        self._user_service_config = user_service_config
        self._user_service = UserMetricsService(
            self._user_service_config, redis_connection)

    def check(self):
        """ Check if the current user quota surpasses the current quota """
        if re.match('geocoder_*',
                    self._user_service_config.service_type) is not None:
            return self.__check_geocoder_quota()
        elif re.match('here_isolines',
                      self._user_service_config.service_type) is not None:
            return self.__check_isolines_quota()
        elif re.match('routing_mapzen',
                      self._user_service_config.service_type) is not None:
            return self.__check_routing_quota()
        elif re.match('obs_*',
                      self._user_service_config.service_type) is not None:
            return self.__check_data_observatory_quota()
        else:
            return False

    def __check_geocoder_quota(self):
        # We don't have quota check for google geocoder
        if self._user_service_config.google_geocoder:
            return True

        user_quota = self._user_service_config.geocoding_quota
        today = date.today()
        service_type = self._user_service_config.service_type
        current_used = self._user_service.used_quota(service_type, today)
        soft_geocoding_limit = self._user_service_config.soft_geocoding_limit

        if soft_geocoding_limit or (user_quota > 0 and current_used <= user_quota):
            return True
        else:
            return False

    def __check_isolines_quota(self):
        user_quota = self._user_service_config.isolines_quota
        today = date.today()
        service_type = self._user_service_config.service_type
        current_used = self._user_service.used_quota(service_type, today)
        soft_isolines_limit = self._user_service_config.soft_isolines_limit

        if soft_isolines_limit or (user_quota > 0 and current_used <= user_quota):
            return True
        else:
            return False

    def __check_routing_quota(self):
        user_quota = self._user_service_config.monthly_quota
        today = date.today()
        service_type = self._user_service_config.service_type
        current_used = self._user_service.used_quota(service_type, today)

        if (user_quota > 0 and current_used <= user_quota):
            return True
        else:
            return False

    def __check_data_observatory_quota(self):
        user_quota = self._user_service_config.monthly_quota
        soft_limit = self._user_service_config.soft_limit
        today = date.today()
        service_type = self._user_service_config.service_type
        current_used = self._user_service.used_quota(service_type, today)

        if soft_limit or (user_quota > 0 and current_used <= user_quota):
            return True
        else:
            return False

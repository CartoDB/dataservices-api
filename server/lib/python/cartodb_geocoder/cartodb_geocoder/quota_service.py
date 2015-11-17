import user_service
import config_helper
from datetime import date

class QuotaService:
    """ Class to manage all the quota operation for the Geocoder SQL API Extension """

    def __init__(self, user_config, geocoder_config, redis_connection):
        self._user_config = user_config
        self._geocoder_config = geocoder_config
        self._user_service = user_service.UserService(self._user_config,
            self._geocoder_config.service_type, redis_connection)

    def check_user_quota(self):
        """ Check if the current user quota surpasses the current quota """
        # We don't have quota check for google geocoder
        if self._geocoder_config.google_geocoder:
            return True

        user_quota = self._geocoder_config.nokia_monthly_quota
        today = date.today()
        service_type = self._geocoder_config.service_type
        current_used = self._user_service.used_quota(service_type, today.year, today.month)
        soft_geocoder_limit = self._geocoder_config.nokia_soft_limit

        print "User quota: {0} --- current_used: {1} --- limit: {2}".format(user_quota, current_used, soft_geocoder_limit)

        return True if soft_geocoder_limit or current_used <= user_quota else False

    def increment_geocoder_use(self, amount=1):
        self._user_service.increment_service_use(self._geocoder_config.service_type)
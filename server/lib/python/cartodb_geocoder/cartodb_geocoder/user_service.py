from datetime import date, timedelta
from dateutil.relativedelta import relativedelta


class UserService:
    """ Class to manage all the user info """

    SERVICE_GEOCODER_NOKIA = 'geocoder_here'
    SERVICE_GEOCODER_GOOGLE = 'geocoder_google'
    SERVICE_GEOCODER_CACHE = 'geocoder_cache'

    GEOCODING_QUOTA_KEY = "geocoding_quota"
    GEOCODING_SOFT_LIMIT_KEY = "soft_geocoder_limit"

    REDIS_CONNECTION_KEY = "redis_connection"
    REDIS_CONNECTION_HOST = "redis_host"
    REDIS_CONNECTION_PORT = "redis_port"
    REDIS_CONNECTION_DB = "redis_db"

    def __init__(self, user_geocoder_config, redis_connection):
        self._user_geocoder_config = user_geocoder_config
        self._redis_connection = redis_connection
        self._username = user_geocoder_config.username
        self._orgname = user_geocoder_config.organization

    def used_quota(self, service_type, date):
        """ Recover the used quota for the user in the current month """
        date_from, date_to = self.__current_billing_cycle()
        current_use = 0
        success_responses = self.__get_metrics(service_type,
                                               'success_responses', date_from,
                                               date_to)
        empty_responses = self.__get_metrics(service_type,
                                             'empty_responses', date_from,
                                             date_to)
        current_use += (success_responses + empty_responses)
        if service_type == self.SERVICE_GEOCODER_NOKIA:
            cache_hits = self.__get_metrics(self.SERVICE_GEOCODER_CACHE,
                                            'success_responses', date_from,
                                            date_to)
            current_use += cache_hits

        return current_use

    def increment_service_use(self, service_type, metric, date=date.today(), amount=1):
        """ Increment the services uses in monthly and daily basis"""
        self.__increment_user_uses(service_type, metric, date, amount)
        if self._orgname:
            self.__increment_organization_uses(service_type, metric, date, amount)

    # Private functions

    def __increment_user_uses(self, service_type, metric, date, amount):
        redis_prefix = self.__parse_redis_prefix("user", self._username,
                                                 service_type, metric, date)
        self._redis_connection.zincrby(redis_prefix, date.day, amount)

    def __increment_organization_uses(self, service_type, metric, date, amount):
        redis_prefix = self.__parse_redis_prefix("org", self._orgname,
                                                 service_type, metric, date)
        self._redis_connection.zincrby(redis_prefix, date.day, amount)

    def __parse_redis_prefix(self, prefix, entity_name, service_type, metric, date):
        yearmonth_key = date.strftime('%Y%m')
        redis_name = "{0}:{1}:{2}:{3}:{4}".format(prefix, entity_name,
                                              service_type, metric,
                                              yearmonth_key)

        return redis_name

    def __get_metrics(self, service, metric, date_from, date_to):
        aggregated_metric = 0
        key_prefix = "org" if self._orgname else "user"
        entity_name = self._orgname if self._orgname else self._username
        for date in self.__generate_date_range(date_from, date_to):
            redis_prefix = self.__parse_redis_prefix(key_prefix, entity_name,
                                                     service, metric, date)
            score = self._redis_connection.zscore(redis_prefix, date.day)
            aggregated_metric += score if score else 0
        return aggregated_metric

    def __current_billing_cycle(self):
        """ Return the begining and end date for the current billing cycle """
        end_period_day = self._user_geocoder_config.period_end_date.day
        today = date.today()
        if end_period_day > today.day:
            temp_date = today + relativedelta(months=-1)
            date_from = date(temp_date.year, temp_date.month, end_period_day)
        else:
            date_from = date(today.year, today.month, end_period_day)

        return date_from, today

    def __generate_date_range(self, date_from, date_to):
        for n in range(int((date_to - date_from).days)):
            yield date_from + timedelta(n)

import json

from cartodb_services.config.service_configuration import ServiceConfiguration

class RateLimitsConfig(object):
    """
    Value object that represents the configuration needed to rate-limit services
    """

    def __init__(self,
                 service,
                 username,
                 limit,
                 period):
        self._service = service
        self._username = username
        self._limit = limit and int(limit)
        self._period = period and int(period)

    def __eq__(self, other):
        return self.__dict__ == other.__dict__

    # service this limit applies to
    @property
    def service(self):
        return self._service

    # user this limit applies to
    @property
    def username(self):
        return self._username

    # rate period in seconds
    @property
    def period(self):
        return self._period

    # rate limit in seconds
    @property
    def limit(self):
        return self._limit

    def is_limited(self):
        return self._limit and self._limit > 0 and self._period and self._period > 0

class RateLimitsConfigBuilder(object):
    """
    Build a rate limits configuration obtaining the parameters
    from the user/org/server configuration.
    """

    def __init__(self, server_conf, user_conf, org_conf, service, username, orgname):
        self._server_conf = server_conf
        self._user_conf = user_conf
        self._org_conf = org_conf
        self._service = service
        self._username = username
        self._orgname = orgname

    def get(self):
        # Order of precedence is user_conf, org_conf, server_conf

        rate_limit_key = "{0}_rate_limit".format(self._service)

        rate_limit_json = self._user_conf.get(rate_limit_key, None) or self._org_conf.get(rate_limit_key, None)
        if (rate_limit_json):
            rate_limit = rate_limit_json and json.loads(rate_limit_json)
        else:
            rate_limit = self._server_conf.get('rate_limits', {}).get(self._service, {})

        return RateLimitsConfig(self._service,
                                self._username,
                                rate_limit.get('limit', None),
                                rate_limit.get('period', None))


class RateLimitsConfigSetter(object):

    def __init__(self, service, username, orgname=None):
        self._service = service
        self._service_config = ServiceConfiguration(service, username, orgname)

    def set_user_rate_limits(self, rate_limits_config):
        # Note we allow copying a config from another user/service, so we
        # ignore rate_limits:config.service and rate_limits:config.username
        rate_limit_key = "{0}_rate_limit".format(self._service)
        if rate_limits_config.is_limited():
            rate_limit = {'limit': rate_limits_config.limit, 'period': rate_limits_config.period}
            rate_limit_json = json.dumps(rate_limit)
            self._service_config.user.set(rate_limit_key, rate_limit_json)
        else:
            self._service_config.user.remove(rate_limit_key)

    def set_org_rate_limits(self, rate_limits_config):
        rate_limit_key = "{0}_rate_limit".format(self._service)
        if rate_limits_config.is_limited():
            rate_limit = {'limit': rate_limits_config.limit, 'period': rate_limits_config.period}
            rate_limit_json = json.dumps(rate_limit)
            self._service_config.org.set(rate_limit_key, rate_limit_json)
        else:
            self._service_config.org.remove(rate_limit_key)

    def set_server_rate_limits(self, rate_limits_config):
        rate_limits = self._service_config.server.get('rate_limits', {})
        if rate_limits_config.is_limited():
            rate_limits[self._service] = {'limit': rate_limits_config.limit, 'period': rate_limits_config.period}
        else:
            rate_limits.pop(self._service, None)
        if rate_limits:
            self._service_config.server.set('rate_limits', rate_limits)
        else:
            self._service_config.server.remove('rate_limits')


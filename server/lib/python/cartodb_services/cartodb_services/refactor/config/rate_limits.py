import json
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

    def __init__(self, server_conf, user_conf, org_conf, service, user, org):
        self._server_conf = server_conf
        self._user_conf = user_conf
        self._org_conf = org_conf
        self._service = service
        self._username = user
        self._orgname = org

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

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

class RateLimitsConfigLegacyBuilder(object):
    """
    Build a RateLimitsConfig object using the legacy configuration
    classes ...
    instead of the refactored ...
    """

    def __init__(self, redis_connection, db_conn, service, user, org):
        self._service = service
        self._username = user
        self._orgname = org
        self._redis_connection = redis_connection
        self._db_conn = db_conn

    def get(self):
        rate_limit = self.__get_rate_limit()
        return RateLimitsConfig(self._service,
                                self._username,
                                rate_limit.get('limit', None),
                                rate_limit.get('period', None))

    def __get_rate_limit(self):
        rate_limit = {}
        rate_limit_key = "{0}_rate_limit".format(self._service)
        user_key = "rails:users:{0}".format(self._username)
        rate_limit_json = self.__get_redis_config(user_key, rate_limit_key)
        if not rate_limit_json and self._orgname:
            org_key = "rails:orgs:{0}".format(self._orgname)
            rate_limit_json = self.__get_redis_config(org_key, rate_limit_key)
        if rate_limit_json:
            rate_limit = json.loads(rate_limit_json)
        else:
            conf_key = 'rate_limits'
            sql = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(conf_key)
            try:
                conf = self._db_conn.execute(sql, 1)[0]['conf']
            except Exception:
                conf = None
            if conf:
                rate_limit = json.loads(conf).get(self._service)
        return rate_limit or {}

    def __get_redis_config(self, basekey, param):
        config = self._redis_connection.hgetall(basekey)
        return config and config.get(param)

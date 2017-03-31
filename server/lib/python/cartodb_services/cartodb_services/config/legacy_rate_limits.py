import json
from rate_limits import RateLimitsConfig

class RateLimitsConfigLegacyBuilder(object):
    """
    Build a RateLimitsConfig object using the *legacy* configuration classes
    """

    def __init__(self, redis_connection, db_conn, service, username, orgname):
        self._service = service
        self._username = username
        self._orgname = orgname
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
            sql = "SELECT cdb_dataservices_server.CDB_Conf_GetConf('{0}') as conf".format(conf_key)
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

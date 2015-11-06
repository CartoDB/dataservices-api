import redis
from datetime import date

class QuotaService:
    """ Class to manage all the quota operation for the Geocoder SQL API Extension """

    GEOCODING_QUOTA_KEY = "geocoding_quota"

    def __init__(self, logger, user_id, transaction_id, redis_host='localhost', redis_port=6379, redis_db = 5):
        self.logger = logger
        self.user_id = user_id
        self.transaction_id = transaction_id
        self.redis_host = redis_host
        self.redis_port = redis_port
        self.redis_db = redis_db
        self.redis_conn = self.__get_redis_connection()

    def check_user_quota(self):
        """ Check if the current user quota surpasses the current quota """
        # TODO We need to add the hard/soft limit flag for the geocoder
        user_quota = self.get_user_quota()
        current_used = self.get_current_used_quota()
        self.logger.debug("User quota: {0} --- Current used quota: {1}".format(user_quota, current_used))
        return True if (current_used + 1) < user_quota else False

    def get_user_quota(self):
        # Check for exceptions or redis timeout
        user_quota = self.redis_conn.hget(self.__get_user_redis_key(), self.GEOCODING_QUOTA_KEY)
        return int(user_quota)

    def get_current_used_quota(self):
        """ Recover the used quota for the user in the current month """
        # Check for exceptions or redis timeout
        current_used = 0
        for _, value in self.redis_conn.hscan_iter(self.__get_month_redis_key()):
            current_used += int(value)
        return current_used

    def increment_georeference_use(self, amount=1):
        """ Increment the geocoder use in 1 """
        # TODO Manage exceptions or timeout
        self.redis_conn.hincrby(self.__get_month_redis_key(), self.transaction_id,amount)

    def __get_redis_connection(self):
        pool = redis.ConnectionPool(host=self.redis_host, port=self.redis_port, db=self.redis_db)
        return redis.Redis(connection_pool=pool)

    def __get_month_redis_key(self):
        today = date.today()
        return "geocoder:{0}:{1}".format(self.user_id, today.strftime("%Y%m"))

    def __get_user_redis_key(self):
        return "geocoder:{0}".format(self.user_id)
import redis
from datetime import date

class QuotaService:
    """ Class to manage all the quota operation for the Geocoder SQL API Extension """

    GEOCODING_QUOTA_KEY = "geocoding_quota"

    def __init__(self, logger, user_id, transaction_id):
        self.logger = logger
        self.user_id = user_id
        self.transaction_id = transaction_id
        self.redis_conn = self.__get_redis_connection()

    def check_user_quota(self):
        """ Get the user quota and add it to redis in order to cache it """
        # TODO: Check if the redis key geocoder::user_id::tx_id exists:
        #       a) If exists check the quota
        user_quota = self.get_user_quota()
        current_used = self.get_current_used_quota()
        return True if (current_used + 1) < user_quota else False

    def get_user_quota(self):
        return self.redis_conn.hget(self.__get_user_redis_key(), self.GEOCODING_QUOTA_KEY)

    def get_current_used_quota(self):
        # TODO: Check if exist geocoder:user_id:year_month , if yes sum up all of it
        current_used = 0
        for _, value in self.redis_conn.hscan_iter(self.__get_month_redis_key()):
            current_used += int(value)
        return current_used

    def increment_georeference_use(self):
        pass

    def __get_redis_connection(self):
        pool = redis.ConnectionPool(host='localhost', port=6379, db=5)
        return redis.Redis(connection_pool=pool)

    def __get_month_redis_key(self):
        today = date.today()
        return "geocoder:{0}:{1}".format(self.user_id, today.strftime("%Y%m"))

    def __get_user_redis_key(self):
        return "geocoder:{0}".format(self.user_id)
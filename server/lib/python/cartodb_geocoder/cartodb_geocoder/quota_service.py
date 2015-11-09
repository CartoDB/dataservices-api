import redis
from datetime import date

class QuotaService:
    """ Class to manage all the quota operation for the Geocoder SQL API Extension """

    GEOCODING_QUOTA_KEY = "geocoding_quota"
    REDIS_CONNECTION_KEY = "redis_connection"
    REDIS_CONNECTION_HOST = "redis_host"
    REDIS_CONNECTION_PORT = "redis_port"
    REDIS_CONNECTION_DB = "redis_db"

    def __init__(self, logger, user_id, transaction_id, **kwargs):
        self.logger = logger
        self.user_id = user_id
        self.transaction_id = transaction_id
        self.cache = {}

        if self.REDIS_CONNECTION_KEY in kwargs:
            self.redis_connection = self.__get_redis_connection(redis_connection=kwargs[self.REDIS_CONNECTION_KEY])
        else:
            if self.REDIS_CONNECTION_HOST not in kwargs:
                raise "You have to provide redis configuration"
            redis_config = self.__build_redis_config(kwargs)
            self.redis_connection = self.__get_redis_connection(redis_config = redis_config)


    def check_user_quota(self):
        """ Check if the current user quota surpasses the current quota """
        # TODO We need to add the hard/soft limit flag for the geocoder
        user_quota = self.get_user_quota()
        current_used = self.get_current_used_quota()
        self.logger.debug("User quota: {0} --- Current used quota: {1}".format(user_quota, current_used))
        return True if (current_used + 1) < user_quota else False

    def get_user_quota(self):
        # Check for exceptions or redis timeout
        user_quota = self.redis_connection.hget(self.__get_user_redis_key(), self.GEOCODING_QUOTA_KEY)
        return int(user_quota) if user_quota else 0

    def get_current_used_quota(self):
        """ Recover the used quota for the user in the current month """
        # Check for exceptions or redis timeout
        current_used = 0
        for _, value in self.redis_connection.hscan_iter(self.__get_month_redis_key()):
            current_used += int(value)
        return current_used

    def increment_georeference_use(self, amount=1):
        # TODO Manage exceptions or timeout
        self.redis_connection.hincrby(self.__get_month_redis_key(), self.transaction_id,amount)

    def get_redis_connection(self):
        return self.redis_connection

    def __get_redis_connection(self, redis_connection=None, redis_config=None):
        if redis_connection:
            self.__add_redis_connection_to_cache(redis_connection)
            conn = redis_connection
        else:
            conn = self.__create_redis_connection(redis_config)

        return conn

    def __create_redis_connection(self, redis_config):
        # Pool not needed
        # Try to not create a connection every time, add it to a cache
        self.logger.debug("Connecting to redis...")
        pool = redis.ConnectionPool(host=redis_config['host'], port=redis_config['port'], db=redis_config['db'])
        conn = redis.Redis(connection_pool=pool)
        self.__add_redis_connection_to_cache(conn)
        return conn

    def __build_redis_config(self, config):
        redis_host = config[self.REDIS_CONNECTION_HOST] if self.REDIS_CONNECTION_HOST in config else 'localhost'
        redis_port = config[self.REDIS_CONNECTION_PORT] if self.REDIS_CONNECTION_PORT in config else 6379
        redis_db = config[self.REDIS_CONNECTION_DB] if self.REDIS_CONNECTION_DB in config else 5
        return {'host': redis_host, 'port': redis_port, 'db': redis_db}

    def __add_redis_connection_to_cache(self, connection):
        """ Cache the redis connection to avoid reach the limit of connections """
        self.cache = {self.transaction_id: {self.REDIS_CONNECTION_KEY: connection}}

    def __get_month_redis_key(self):
        today = date.today()
        return "geocoder:{0}:{1}".format(self.user_id, today.strftime("%Y%m"))

    def __get_user_redis_key(self):
        return "geocoder:{0}".format(self.user_id)
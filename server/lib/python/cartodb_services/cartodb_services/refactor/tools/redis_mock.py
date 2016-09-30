class RedisConnectionMock(object):
    """ Simple class to mock a dummy behaviour for Redis related functions """

    def zscore(self, redis_prefix, day):
        pass

    def zincrby(self, redis_prefix, day, amount):
        pass
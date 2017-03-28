from rratelimit import Limiter

class RateLimiter:

    def __init__(self, rate_limits_config, redis_connection):
        self._config = rate_limits_config
        self._limiter = None
        if (self._config.is_limited()):
            self._limiter = Limiter(redis_connection,
                                    action=self._config.service,
                                    limit=self._config.limit,
                                    period=self._config.period)

    def check(self):
        ok = True
        if (self._limiter):
            ok = self._limiter.checked_insert(self._config.username)
        return ok

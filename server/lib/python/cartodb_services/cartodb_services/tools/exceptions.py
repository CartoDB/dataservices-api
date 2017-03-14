class RateLimitExceeded(Exception):
    def __str__(self):
            return repr('Rate limit exceeded')

import time
import random
from datetime import datetime
from cartodb_services.tools.exceptions import TimeoutException
import re

DEFAULT_RETRY_TIMEOUT = 60
DEFAULT_QUERIES_PER_SECOND = 10

TOMTOM_403_RATE_LIMIT_HEADERS = [
    'Account Over Queries Per Second Limit',
    'Developer Over Qps'
]
TOMTOM_DETAIL_HEADER = 'X-Error-Detail-Header'
TOMTOM_403_RATE_LIMIT_HEADER_PATTERN = re.compile('|'.join(TOMTOM_403_RATE_LIMIT_HEADERS), re.IGNORECASE)

def qps_retry(original_function=None, **options):
    """ Query Per Second retry decorator
        The intention of this decorator is to retry requests against third
        party services that has QPS restriction.
        Parameters:
            - timeout: Maximum number of seconds to retry
            - qps: Allowed queries per second. This parameter is used to
                   calculate the next time to retry the request
    """
    if original_function is not None:
        def wrapped_function(*args, **kwargs):
            timeout = options.get('timeout', DEFAULT_RETRY_TIMEOUT)
            qps = options.get('qps', DEFAULT_QUERIES_PER_SECOND)
            provider = options.get('provider', None)
            return QPSService(retry_timeout=timeout, queries_per_second=qps, provider=provider).call(original_function, *args, **kwargs)
        return wrapped_function
    else:
        def partial_wrapper(func):
            return qps_retry(func, **options)
        return partial_wrapper


class QPSService:

    def __init__(self, queries_per_second, retry_timeout, provider):
        self._queries_per_second = queries_per_second
        self._retry_timeout = retry_timeout
        self._provider = provider

    def call(self, fn, *args, **kwargs):
        start_time = datetime.now()
        attempt_number = 1
        while True:
            try:
                return fn(*args, **kwargs)
            except Exception as e:
                response = getattr(e, 'response', None)
                if response is not None:
                    if response.status_code == 429:
                        self.retry(start_time, attempt_number)
                    else:
                        raise e
                else:
                    raise e
            attempt_number += 1

    def retry(self, first_request_time, retry_count):
        elapsed = datetime.now() - first_request_time
        if elapsed.total_seconds() > self._retry_timeout:
            raise TimeoutException()

        # inverse qps * (1.5 ^ i) is an increased sleep time of 1.5x per
        # iteration.
        delay = (1.0/self._queries_per_second) * 1.5 ** retry_count

        # https://www.awsarchitectureblog.com/2015/03/backoff.html
        # https://github.com/googlemaps/google-maps-services-python/blob/master/googlemaps/client.py#L193
        sleep_time = delay * (random.random() + 0.5)

        time.sleep(sleep_time)

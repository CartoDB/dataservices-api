import time
import random
from datetime import datetime
from exceptions import TimeoutException

DEFAULT_RETRY_TIMEOUT = 60


def qps_retry(f):
    def wrapped_f(*args, **kw):
        return QPSService().call(f, *args, **kw)
    return wrapped_f


class QPSService:

    def __init__(self, queries_per_second=10,
                 retry_timeout=DEFAULT_RETRY_TIMEOUT):
        self._queries_per_second = queries_per_second
        self._retry_timeout = retry_timeout

    def call(self, fn, *args, **kwargs):
        start_time = datetime.now()
        attempt_number = 1
        while True:
            try:
                return fn(*args, **kwargs)
            except Exception as e:
                if hasattr(e, 'response') and (e.response.status_code == 429):
                    self.retry(start_time, attempt_number)
                else:
                    raise e
            attempt_number += 1

    def retry(self, first_request_time, retry_count):
        elapsed = datetime.now() - first_request_time
        if elapsed.seconds > self._retry_timeout:
            raise TimeoutException()

        # inverse qps * (1.5 ^ i) is an increased sleep time of 1.5x per
        # iteration.
        delay = (1.0/self._queries_per_second) * 1.5 ** retry_count

        # https://www.awsarchitectureblog.com/2015/03/backoff.html
        # https://github.com/googlemaps/google-maps-services-python/blob/master/googlemaps/client.py#L193
        sleep_time = delay * (random.random() + 0.5)

        time.sleep(sleep_time)

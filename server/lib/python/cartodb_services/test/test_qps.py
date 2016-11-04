import requests
from unittest import TestCase
from nose.tools import assert_raises
from datetime import datetime, date
from cartodb_services.mapzen.qps import qps_retry
from cartodb_services.mapzen.exceptions import ServiceException, TimeoutException
import requests_mock
import mock

requests_mock.Mocker.TEST_PREFIX = 'test_'

@requests_mock.Mocker()
class TestQPS(TestCase):
    QPS_ERROR_MESSAGE = "Queries per second exceeded: Queries exceeded (10 allowed)"

    def test_qps_timeout(self, req_mock):
        class TestClass:
            @qps_retry(timeout=0.001, qps=100)
            def test(self):
                response = requests.get('http://localhost/test_qps')
                if response.status_code == 429:
                    raise ServiceException('Error 429', response)

        def _text_cb(request, context):
            context.status_code = 429
            return self.QPS_ERROR_MESSAGE

        req_mock.register_uri('GET', 'http://localhost/test_qps',
                       text=_text_cb)
        with self.assertRaises(TimeoutException):
            c = TestClass()
            c.test()

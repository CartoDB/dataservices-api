from test_helper import *
from cartodb_services.metrics import MetricsDataGatherer
from unittest import TestCase
from mock import Mock, MagicMock
from nose.tools import assert_raises
from datetime import datetime, date


class TestMetricsDataGatherer(TestCase):

    def setUp(self):
        plpy_mock_config()


    def test_should_use_multiple_instances_for_multiples_requests(self):
        plpy_mock._define_result("select txid_current", [{'txid': 100}])
        MetricsDataGatherer.add('test', 1)
        plpy_mock._define_result("select txid_current", [{'txid': 101}])
        MetricsDataGatherer.add('test', 2)
        plpy_mock._define_result("select txid_current", [{'txid': 100}])
        assert MetricsDataGatherer.get_element('test') is 1
        plpy_mock._define_result("select txid_current", [{'txid': 101}])
        assert MetricsDataGatherer.get_element('test') is 2

#!/usr/local/bin/python
# -*- coding: utf-8 -*-

from unittest import TestCase
from mock import Mock, MagicMock
from nose.tools import assert_not_equal, assert_equal, assert_true
from cartodb_services.geocoder import run_street_point_geocoder


class TestRunStreetPointGeocoder(TestCase):
    def test_count_increment_total_and_failed_service_use_on_error(self):
        quota_service_mock = Mock()

        service_manager_mock = Mock()
        service_manager_mock.quota_service = quota_service_mock
        service_manager_mock.assert_within_limits = \
            Mock(side_effect=Exception('Fail!'))

        searches = []

        logger_config_mock = MagicMock(min_log_level='debug',
                                       log_file_path='/tmp/ptest.log')
        with(self.assertRaises(BaseException)):
            run_street_point_geocoder(Mock(),
                                      {'logger_config': logger_config_mock},
                                      None,
                                      service_manager_mock,
                                      None, None, searches)

        quota_service_mock.increment_total_service_use. \
            assert_called_once_with(len(searches))

        quota_service_mock.increment_failed_service_use. \
            assert_called_once_with(len(searches))

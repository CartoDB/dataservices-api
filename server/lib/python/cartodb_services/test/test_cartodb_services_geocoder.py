#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import json
from unittest import TestCase
from mock import Mock, MagicMock
from nose.tools import assert_not_equal, assert_equal, assert_true
from cartodb_services.tools import QuotaExceededException
from cartodb_services.geocoder import run_street_point_geocoder, StreetGeocoderSearch


SEARCH_FIXTURES = {
    'two': [
        StreetGeocoderSearch(id=1, address='Paseo Zorrilla 1, Valladolid',
                             city=None, state=None, country=None),
        StreetGeocoderSearch(id=2, address='Paseo Zorrilla 2, Valladolid',
                             city=None, state=None, country=None)
    ],
    'wrong': [
        StreetGeocoderSearch(id=100, address='deowpfjoepwjfopejwpofjewpojgf',
                             city=None, state=None, country=None),
    ],
    'error': [
        StreetGeocoderSearch(id=200, address=None, city=None, state=None,
                             country=None),
    ],
    'broken_middle': [
        StreetGeocoderSearch(id=301, address='Paseo Zorrilla 1, Valladolid',
                             city=None, state=None, country=None),
        StreetGeocoderSearch(id=302, address='Marsopolis',
                             city=None, state=None, country=None),
        StreetGeocoderSearch(id=303, address='Paseo Zorrilla 2, Valladolid',
                             city=None, state=None, country=None)
    ],
}

BULK_RESULTS_FIXTURES = {
    'two': [
        (1, [0, 0], {}),
        (2, [0, 0], {}),
    ],
    'wrong': [
        (100, [], {})
    ],
    'error': [
        (200, [], {'error': 'Something wrong happened'})
    ],
    'broken_middle': [
        (301, [0, 0], {}),
        (302, ['a', 'b'], {}),
        (303, [0, 0], {}),
    ]
}

EXPECTED_RESULTS_FIXTURES = {
    'two': [
        [1, [0, 0], '{}'],
        [2, [0, 0], '{}'],
    ],
    'wrong': [
        [100, None, '{}']
    ],
    'error': [
        [200, None, '{"error": "Something wrong happened"}']
    ],
    'broken_middle': [
        [301, [0, 0], '{}'],
        [302, None, '{"processing_error": "Error: NO!"}'],
        [303, [0, 0], '{}'],
    ]
}


class TestRunStreetPointGeocoder(TestCase):
    def _run_geocoder(self, plpy=None, gd=None, geocoder=None,
                      service_manager=None, username=None, orgname=None,
                      searches=None):
        return run_street_point_geocoder(
            plpy if plpy else self.plpy_mock,
            gd if gd else self.gd_mock,
            geocoder if geocoder else self.geocoder_mock,
            service_manager if service_manager else self.service_manager_mock,
            username if username else 'any_username',
            orgname if orgname else None,
            json.dumps(searches) if searches else '[]')

    def setUp(self):
        point = [0,0]
        self.plpy_mock = Mock()
        self.plpy_mock.execute = MagicMock(return_value=[{'the_geom': point}])

        self.logger_config_mock = MagicMock(min_log_level='debug',
                                            log_file_path='/tmp/ptest.log',
                                            rollbar_api_key=None)
        self.gd_mock = {'logger_config': self.logger_config_mock}

        self.geocoder_mock = Mock()

        self.quota_service_mock = Mock()

        self.service_manager_mock = Mock()
        self.service_manager_mock.quota_service = self.quota_service_mock
        self.service_manager_mock.assert_within_limits = MagicMock()

    def test_count_increment_total_and_failed_service_use_on_error(self):
        self.service_manager_mock.assert_within_limits = \
            Mock(side_effect=Exception('Fail!'))
        searches = []

        with(self.assertRaises(BaseException)):
            self._run_geocoder(service_manager=self.service_manager_mock,
                               searches=searches)

        self.quota_service_mock.increment_total_service_use. \
            assert_called_once_with(len(searches))
        self.quota_service_mock.increment_failed_service_use. \
            assert_called_once_with(len(searches))

    def test_count_increment_failed_service_use_on_quota_error(self):
        self.service_manager_mock.assert_within_limits = \
            Mock(side_effect=QuotaExceededException())
        searches = SEARCH_FIXTURES['two']

        result = self._run_geocoder(service_manager=self.service_manager_mock,
                                    searches=searches)
        assert_equal(result, [])
        self.quota_service_mock.increment_failed_service_use. \
            assert_called_once_with(len(searches))

    def test_increment_success_service_use_on_complete_response(self):
        searches = SEARCH_FIXTURES['two']
        results = [
            (1, [0, 0], {}),
            (2, [0, 0], {}),
        ]
        expected_results = [
            [1, [0, 0], '{}'],
            [2, [0, 0], '{}'],
        ]
        self.geocoder_mock.bulk_geocode = MagicMock(return_value=results)

        result = self._run_geocoder(geocoder=self.geocoder_mock,
                                    searches=searches)
        assert_equal(result, expected_results)
        self.quota_service_mock.increment_success_service_use. \
            assert_called_once_with(len(results))

    def test_increment_empty_service_use_on_complete_response(self):
        searches = SEARCH_FIXTURES['two']
        results = []
        self.geocoder_mock.bulk_geocode = MagicMock(return_value=results)

        result = self._run_geocoder(geocoder=self.geocoder_mock,
                                    searches=searches)

        assert_equal(result, results)
        self.quota_service_mock.increment_empty_service_use. \
            assert_called_once_with(len(searches))

    def test_increment_mixed_empty_service_use_on_complete_response(self):
        searches = SEARCH_FIXTURES['two'] + SEARCH_FIXTURES['wrong']
        bulk_results = BULK_RESULTS_FIXTURES['two'] + BULK_RESULTS_FIXTURES['wrong']
        self.geocoder_mock.bulk_geocode = MagicMock(return_value=bulk_results)

        result = self._run_geocoder(geocoder=self.geocoder_mock,
                                    searches=searches)

        assert_equal(result, EXPECTED_RESULTS_FIXTURES['two'] + EXPECTED_RESULTS_FIXTURES['wrong'])
        self.quota_service_mock.increment_success_service_use. \
            assert_called_once_with(len(SEARCH_FIXTURES['two']))
        self.quota_service_mock.increment_empty_service_use. \
            assert_called_once_with(len(SEARCH_FIXTURES['wrong']))

    def test_increment_mixed_error_service_use_on_complete_response(self):
        searches = SEARCH_FIXTURES['two'] + SEARCH_FIXTURES['error']
        bulk_results = BULK_RESULTS_FIXTURES['two'] + BULK_RESULTS_FIXTURES['error']
        self.geocoder_mock.bulk_geocode = MagicMock(return_value=bulk_results)

        result = self._run_geocoder(geocoder=self.geocoder_mock,
                                    searches=searches)

        assert_equal(result, EXPECTED_RESULTS_FIXTURES['two'] + EXPECTED_RESULTS_FIXTURES['error'])
        self.quota_service_mock.increment_success_service_use. \
            assert_called_once_with(len(SEARCH_FIXTURES['two']))
        self.quota_service_mock.increment_failed_service_use. \
            assert_called_once_with(len(SEARCH_FIXTURES['error']))

    def test_controlled_failure_on_query_break(self):
        searches = SEARCH_FIXTURES['broken_middle']
        bulk_results = BULK_RESULTS_FIXTURES['broken_middle']
        self.geocoder_mock.bulk_geocode = MagicMock(return_value=bulk_results)
        def break_on_302(*args):
            if len(args) == 3:
                plan, values, limit = args
                if values[0] == 'a':
                    raise Exception('NO!')

            return [{'the_geom': [0,0]}]
        self.plpy_mock.execute = break_on_302

        result = self._run_geocoder(geocoder=self.geocoder_mock,
                                    searches=searches)

        assert_equal(result, EXPECTED_RESULTS_FIXTURES['broken_middle'])
        self.quota_service_mock.increment_success_service_use. \
            assert_called_once_with(2)
        self.quota_service_mock.increment_failed_service_use. \
            assert_called_once_with(1)




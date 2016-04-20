from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal, assert_equal
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestDataObservatoryFunctions(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "https://{0}.{1}/api/v1/sql".format(
            self.env_variables['username'],
            self.env_variables['host'],
            self.env_variables['api_key']
        )

    def test_if_get_demographic_snapshot_is_ok(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_do_get_demographic_snapshot(CDB_LatLng(40.704512, -73.936669))".format(
                    self.env_variables['api_key'])
        routing = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(routing['the_geom'], None)

    def test_if_get_demographic_snapshot_without_api_key_raise_error(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_do_get_demographic_snapshot(CDB_LatLng(40.704512, -73.936669))"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")

    def test_if_get_segment_snapshot_is_ok(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_do_get_segment_snapshot(CDB_LatLng(40.704512, -73.936669))".format(
                    self.env_variables['api_key'])
        routing = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(routing['the_geom'], None)

    def test_if_get_segment_snapshot_without_api_key_raise_error(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_do_get_segment_snapshot(CDB_LatLng(40.704512, -73.936669))"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")

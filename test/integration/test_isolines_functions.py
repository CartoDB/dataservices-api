from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal, assert_equal
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestIsolinesFunctions(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "{0}://{1}.{2}/api/v1/sql".format(
            self.env_variables['schema'],
            self.env_variables['username'],
            self.env_variables['host'],
            self.env_variables['api_key']
        )

    def test_if_select_with_isochrones_is_ok(self):
        query = "SELECT * FROM cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, " \
                "'car', ARRAY[300]::integer[]);&api_key={0}".format(
                    self.env_variables['api_key'])
        isolines = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(isolines['the_geom'], None)

    def test_if_select_with_isochrones_without_api_key_raise_error(self):
        query = "SELECT * FROM cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, " \
                "'car', ARRAY[300]::integer[]);"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")

    def test_if_select_with_isodistance_is_ok(self):
        query = "SELECT * FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, " \
                "'car', ARRAY[300]::integer[]);&api_key={0}".format(
                    self.env_variables['api_key'])
        isolines = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(isolines['the_geom'], None)

    def test_if_select_with_isodistance_without_api_key_raise_error(self):
        query = "SELECT * FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, " \
                "'car', ARRAY[300]::integer[]);"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")

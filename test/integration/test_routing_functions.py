from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal, assert_equal
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestRoutingFunctions(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "https://{0}.{1}/api/v1/sql".format(
            self.env_variables['username'],
            self.env_variables['host'],
            self.env_variables['api_key']
        )

    def test_if_select_with_routing_point_to_point_is_ok(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_route_point_to_point('POINT(-3.70237112 40.41706163)'::geometry, " \
                "'POINT(-3.69909883 40.41236875)'::geometry, 'car', " \
                "ARRAY['mode_type=shortest']::text[])&api_key={0}".format(
                    self.env_variables['api_key'])
        routing = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(routing['the_geom'], None)

    def test_if_select_with_routing_point_to_point_without_api_key_raise_error(self):
        query = "SELECT duration, length, shape as the_geom " \
                "FROM cdb_route_point_to_point('POINT(-3.70237112 40.41706163)'::geometry, " \
                "'POINT(-3.69909883 40.41236875)'::geometry, 'car', " \
                "ARRAY['mode_type=shortest']::text[])"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")

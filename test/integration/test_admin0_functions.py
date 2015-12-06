from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestAdmin0Functions(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "https://{0}.{1}/api/v2/sql?api_key={2}".format(
            self.env_variables['username'],
            self.env_variables['host'],
            self.env_variables['api_key']
        )

    def test_if_select_with_admin0_is_ok(self):
        query = "SELECT cdb_geocode_admin0_polygon(name) as geometry " \
            "FROM {0} LIMIT 1".format(
            self.env_variables['table_name'])
        geometry = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(geometry, None)

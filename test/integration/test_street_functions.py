#!/usr/local/bin/python
# -*- coding: utf-8 -*-

from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal, assert_equal
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestStreetFunctionsSetUp(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "{0}://{1}.{2}/api/v1/sql".format(
            self.env_variables['schema'],
            self.env_variables['username'],
            self.env_variables['host'],
            self.env_variables['api_key']
        )


class TestStreetFunctions(TestStreetFunctionsSetUp):

    def test_if_select_with_street_point_is_ok(self):
        query = "SELECT cdb_geocode_street_point(street) " \
                "as geometry FROM {0} LIMIT 1&api_key={1}".format(
            self.env_variables['table_name'],
            self.env_variables['api_key'])
        geometry = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(geometry['geometry'], None)

    def test_if_select_with_street_without_api_key_raise_error(self):
        query = "SELECT cdb_geocode_street_point(street) " \
                "as geometry FROM {0} LIMIT 1".format(
            self.env_variables['table_name'])
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_equal(e.message[0], "The api_key must be provided")


class TestBulkStreetFunctions(TestStreetFunctionsSetUp):

    def test_full_spec(self):
        query = "select cartodb_id, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point(" \
                "'select 1 as cartodb_id, ''Spain'' as country, " \
                "''Castilla y León'' as state, ''Valladolid'' as city, " \
                "''Plaza Mayor'' as street  " \
                "UNION " \
                "select 2 as cartodb_id, ''Spain'' as country, " \
                "''Castilla y León'' as state, ''Valladolid'' as city, " \
                "''Paseo Zorrilla'' as street' " \
                ", 'street', 'city', 'state', 'country')"
        response = self._run_authenticated(query)

        assert_equal(response['total_rows'], 2)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -3.7074009, 40.415511)
        self._assert_x_y(row_by_cartodb_id[2], -4.7404453, 41.6314339)

    def test_empty_columns(self):
        query = "select *, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point( " \
                "'select * from jsonb_to_recordset(''[" \
                "{\"cartodb_id\": 1, \"address\": \"1901 amphitheatre parkway, mountain view, ca, us\"}" \
                "]''::jsonb) as (cartodb_id integer, address text)', " \
                "'address', '''''', '''''', '''''')"
        response = self._run_authenticated(query)

        assert_equal(response['total_rows'], 1)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -122.0885504, 37.4238657)

    def test_null_columns(self):
        query = "select *, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point( " \
                "'select * from jsonb_to_recordset(''[" \
                "{\"cartodb_id\": 1, \"address\": \"1901 amphitheatre parkway, mountain view, ca, us\"}" \
                "]''::jsonb) as (cartodb_id integer, address text)', " \
                "'address')"
        response = self._run_authenticated(query)

        assert_equal(response['total_rows'], 1)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -122.0885504, 37.4238657)

    def test_batching(self):
        query = "select *, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point( " \
                "'select * from jsonb_to_recordset(''[" \
                "{\"cartodb_id\": 1, \"address\": \"1900 amphitheatre parkway, mountain view, ca, us\"}," \
                "{\"cartodb_id\": 2, \"address\": \"1901 amphitheatre parkway, mountain view, ca, us\"}," \
                "{\"cartodb_id\": 3, \"address\": \"1902 amphitheatre parkway, mountain view, ca, us\"}" \
                "]''::jsonb) as (cartodb_id integer, address text)', " \
                "'address', null, null, null, 2)"
        response = self._run_authenticated(query)

        assert_equal(response['total_rows'], 3)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -122.0875324, 37.4227968)
        self._assert_x_y(row_by_cartodb_id[2], -122.0885504, 37.4238657)
        self._assert_x_y(row_by_cartodb_id[3], -122.0876674, 37.4235729)

    def test_city_column_geocoding(self):
        query = "select *, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point( " \
                "'select * from jsonb_to_recordset(''[" \
                "{\"cartodb_id\": 1, \"city\": \"Valladolid\"}," \
                "{\"cartodb_id\": 2, \"city\": \"Madrid\"}" \
                "]''::jsonb) as (cartodb_id integer, city text)', " \
                "'city')"
        response = self._run_authenticated(query)

        assert_equal(response['total_rows'], 2)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -4.7245321, 41.652251)
        self._assert_x_y(row_by_cartodb_id[2], -3.7037902, 40.4167754)

    def test_free_text_geocoding(self):
        query = "select *, st_x(the_geom), st_y(the_geom) " \
                "FROM cdb_dataservices_client.cdb_bulk_geocode_street_point( " \
                "'select * from (" \
                "select 1 as cartodb_id, ''W 26th Street'' as address, " \
                "null as city , null as state , null as country" \
                ")_x', " \
                "'''Logroño, La Rioja, Spain''')"
        response = self._run_authenticated(query)
        # from nose.tools import set_trace; set_trace()

        assert_equal(response['total_rows'], 1)

        row_by_cartodb_id = self._row_by_cartodb_id(response)
        self._assert_x_y(row_by_cartodb_id[1], -2.4449852, 42.4627195)


    def _run_authenticated(self, query):
        authenticated_query = "{}&api_key={}".format(query,
                                                     self.env_variables[
                                                         'api_key'])
        return IntegrationTestHelper.execute_query_raw(self.sql_api_url,
                                                       authenticated_query)

    def _row_by_cartodb_id(self, response):
        return {r['cartodb_id']: r for r in response['rows']}

    def _assert_x_y(self, row, expected_x, expected_y):
        assert_equal(row['st_x'], expected_x)
        assert_equal(row['st_y'], expected_y)


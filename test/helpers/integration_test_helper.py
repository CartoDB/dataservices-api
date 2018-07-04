import os
import requests
import json

from nose.tools import assert_true


# From https://www.python.org/dev/peps/pep-0485/#proposed-implementation
def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)


def assert_close_enough(xy_a, xy_b, rel_tol=0.0001, abs_tol=0.0005):
    """
    Asserts that the given points are "close enough", in a square.
    :param xy_a: Array of 2 elements, X and Y.
    :param xy_b:  Array of 2 elements, X and Y.
    :param rel_tol: Relative tolerance. Default: 0.001 (0.1%).
    :param abs_tol: Absolute tolerance. Default: 0.0005.
    """

    for i in [0, 1]:
        assert_true(isclose(xy_a[i], xy_b[i], rel_tol, abs_tol),
                    "Coord {} error: {} and {} are not closer than {}, {}".format(
                        i, xy_a[i], xy_b[i], rel_tol, abs_tol
                    ))


class IntegrationTestHelper:

    @classmethod
    def get_environment_variables(cls):
        username = os.environ["GEOCODER_API_TEST_USERNAME"]
        api_key = os.environ["GEOCODER_API_TEST_API_KEY"]
        host = os.environ["GEOCODER_API_TEST_HOST"]
        schema = os.environ["GEOCODER_API_TEST_SCHEMA"]
        table_name = os.environ["GEOCODER_API_TEST_TABLE_NAME"]

        return {
            "username": username,
            "api_key": api_key,
            "schema": schema,
            "host": host,
            "table_name": table_name
        }

    @classmethod
    def execute_query_raw(cls, sql_api_url, query):
        requests.packages.urllib3.disable_warnings()
        query_url = "{0}?q={1}".format(sql_api_url, query)
        print "Executing query: {0}".format(query_url)
        query_response = requests.get(query_url)
        if query_response.status_code != 200:
            raise Exception(json.loads(query_response.text)['error'])
        return json.loads(query_response.text)

    @classmethod
    def execute_query(cls, sql_api_url, query):
        return cls.execute_query_raw(sql_api_url, query)['rows'][0]



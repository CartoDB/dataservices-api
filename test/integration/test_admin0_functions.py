import os, time, requests, json
from unittest import TestCase
from nose.tools import assert_raises


class TestConfigHelper(TestCase):

  def setUp(self):
    username = os.environ["GEOCODER_API_TEST_USERNAME"]
    api_key = os.environ["GEOCODER_API_TEST_API_KEY"]
    host = os.environ["GEOCODER_API_TEST_HOST"]
    self.table_name = os.environ["GEOCODER_API_TEST_TABLE_NAME"]
    self.sql_api_url = "https://{0}.{1}/api/v2/sql?api_key={2}".format(username, host, api_key)

  def test_if_select_with_admin0_is_ok(self):
    query = "SELECT cdb_geocode_admin0_polygon(name) as geometry FROM {0} LIMIT 1".format(self.table_name)
    geometry = self.execute_query(query)
    assert geometry != None

  def build_sql_api_query_url(self, query):
    return "{0}&q={1}".format(self.sql_api_url,query)

  def execute_query(self, query):
    query_url = self.build_sql_api_query_url(query)
    query_response = requests.get(query_url)
    if query_response.status_code != 200:
      raise Exception("Error executing SQL API query")
    query_response_data = json.loads(query_response.text)
    return query_response_data['rows'][0]['geometry']

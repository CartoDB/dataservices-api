import os
import requests
import json


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
    def execute_query(cls, sql_api_url, query):
        requests.packages.urllib3.disable_warnings()
        query_url = "{0}?q={1}".format(sql_api_url, query)
        print "Executing query: {0}".format(query_url)
        query_response = requests.get(query_url)
        if query_response.status_code != 200:
            raise Exception(json.loads(query_response.text)['error'])
        query_response_data = json.loads(query_response.text)

        return query_response_data['rows'][0]

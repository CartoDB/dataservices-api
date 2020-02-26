import getopt
import sys
import time
import subprocess
import os
import re
from helpers.import_helper import ImportHelper


def main():
    opts, args = getopt.getopt(sys.argv[1:], "h", ["help", "host=", "schema="])

    if len(args) < 2:
        usage()
        sys.exit()

    schema = "https"
    host = "cartodb.com"
    username = args[0]
    api_key = args[1]
    table_name = "geocoder_api_test_dataset_".format(int(time.time()))
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("--host"):
            host = opts[0][1]
        elif o in ("--schema"):
            schema = opts[1][1]
        else:
            assert False, "unhandled option"

    try:
        table_name = ImportHelper.import_test_dataset(username, api_key, host,
                                                      schema)
        set_environment_variables(username, api_key, table_name, host, schema)
        execute_tests()
    except Exception as e:
        print(e)
        sys.exit(1)
    finally:
        clean_environment_variables()
        ImportHelper.clean_test_dataset(username, api_key, table_name, host,
                                        schema)


def usage():
    print("""Usage: run_tests.py [options] username api_key
        Options:
        -h: Show this help
        --host: take that host as base (by default is cartodb.com)
        --schema: define the url schema [http/https] (by default https)""")


def execute_tests():
    process = subprocess.Popen(
        ["nosetests", "--where=integration/"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    out, err = process.communicate()
    print(err)
    regexp = re.compile(r'FAILED \(.*\)')
    if regexp.search(err) is not None:
        sys.exit(1)


def set_environment_variables(username, api_key, table_name, host, schema):
    os.environ["GEOCODER_API_TEST_USERNAME"] = username
    os.environ["GEOCODER_API_TEST_API_KEY"] = api_key
    os.environ["GEOCODER_API_TEST_TABLE_NAME"] = table_name
    os.environ["GEOCODER_API_TEST_HOST"] = host
    os.environ["GEOCODER_API_TEST_SCHEMA"] = schema


def clean_environment_variables():
    os.environ.pop("GEOCODER_API_TEST_USERNAME", None)
    os.environ.pop("GEOCODER_API_TEST_API_KEY", None)
    os.environ.pop("GEOCODER_API_TEST_TABLE_NAME", None)
    os.environ.pop("GEOCODER_API_TEST_HOST", None)
    os.environ.pop("GEOCODER_API_TEST_SCHEMA", None)

if __name__ == "__main__":
    main()

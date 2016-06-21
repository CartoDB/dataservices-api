# Geocoder API integration tests
This are the automatic integration tests for geocoder api (both client and server)

### Usage
In order to execute the tests you have to execute the `run_tests.py` python script:

```sh
python run_tests.py [--host=cartodb.com] username api_key
```

You can define the host where is going to execute the SQL API queries to test the
geocoder API. By default the value is `cartodb.com` but you can put the host you need.

### Tests

This suite of tests test the following parts of the geocoding API through the SQL API:

- Admin 0 functions
- Admin 1 functions
- Named places functions
- Postal code functions
- Ip address functions
- Street address functions (This will call Heremaps or Google so it will cost you 2 credits)
- Routing functions
- Isolines functions
- Data Observatory functions


### How to debug the tests
You won't be able to plug a debugger when using the `run_test.py` because of the usage of a subprocess and the piping.

You should be aware that some tests require some extra setup (a test table), that you'll need to do on your own in some cases (check the `ImportHelper.import_test_dataset`)

In order to do so, you need to use plain `nosetests` which comes prepared to that.

First, add this to the python test code:

```python
from nose.tools import set_trace; set_trace()
```

Secondly, execute just your test with this:

```ssh
GEOCODER_API_TEST_USERNAME=your_username \
GEOCODER_API_TEST_API_KEY=your_api_key \
GEOCODER_API_TEST_TABLE_NAME=your_test_table \
GEOCODER_API_TEST_HOST=your_target_test_host \
nosetests --where=integration/ test_data_observatory_functions.py:TestDataObservatoryFunctions.test_if_obs_search_is_ok
```

(replace the environment variables, test file, class and function according to your needs)

TODO: we need to refactor the test code a little to avoid these hindrances

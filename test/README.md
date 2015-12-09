# Geocoder API integration tests
This are the automatic integration tests for geocoder api (both client and server)

### Usage
In order to execute the tests you have to execute the `run_tests` python script:

``` python run_tests.py [--host=cartodb.com] username api_key```

You can define the host where is going to execute the SQL API queries to test the
geocoder API. By default the value is `cartodb.com` but you can put the host you need.

### Tests

This suite of tests test the following parts of the geocoding API through the SQL API:

- Admin 0 functions
- Admin 1 functions
- Named places functions
- Postal code functions
- Ip address functions

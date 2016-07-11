# CartoDB dataservices API python module

This directory contains the python library used by the server side of CARTO LDS (Location Data Services).

It is used from pl/python functions contained in the `cdb_dataservices_server` extension. It goes hand in hand with the extension so please consider running the integration tests.

On the other hand, it is pretty independent from the client, as long as the signatures of the public pl/python functions match.

## Dependencies
See the [[`requirements.txt`]] or better the Basically:
- pip
- redis and hiredis
- dateutil
- googlemaps
- request

## Installation
Install the requirements:
```shell
sudo pip install -r requirements.txt
```

Install the library:
```shell
sudo pip install .
```

NOTE: a system installation is required at present because the library is meant to be used from postgres pl/python, which runs an embedded python interpreter.


## Running the unit tests
Just run `nosetests`
```shell
$ nosetests
.................................................
----------------------------------------------------------------------
Ran 49 tests in 0.131s

OK
```

## Running the integration tests
See the [[../../../../test/README.md]]. Basically, move to the `/test` directory at the top level of this repo and execute the `run_tests.py` script:
```sh
cd $(git rev-parse --show-toplevel)/test
python run_tests.py --host=$YOUR_HOST $YOUR_USERNAME $YOUR_API_KEY
```

## TODO
- Move dependencies expressed in `requirements.txt` to `setup.py`

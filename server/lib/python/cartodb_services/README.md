# CARTO dataservices API python module

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
Just run `nosetests test/`
```shell
$ nosetests test/
......................................................................................................
----------------------------------------------------------------------
Ran 102 tests in 0.122s

OK
```

## Running the integration tests
See the [[../../../../test/README.md]]. Basically, move to the `/test` directory at the top level of this repo and execute the `run_tests.py` script:
```sh
cd $(git rev-parse --show-toplevel)/test
python run_tests.py --host=$YOUR_HOST $YOUR_USERNAME $YOUR_API_KEY
```

## Versioning
Once you're satisfied with your changes, it is time to bump the version number in the `setup.py`. A couple of rules:
- **Backwards compatibility**: in general all changes shall be backwards compatible. Do not remove any code used from the server public `pl/python` functions or you'll run into problems when deploying.
- **Semantic versioning**: we try to stick to [Semantic Versioning 2.0.0](http://semver.org/spec/v2.0.0.html)

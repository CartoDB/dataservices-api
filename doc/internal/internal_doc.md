# Data Services API Internal documentation

* [Existent services](#existent-services)
* [How to add a new service](#how-to-add-a-new-service)

## Existent services

Available at [cartodb_services](https://github.com/CartoDB/geocoder-api/tree/master/server/lib/python/cartodb_services/cartodb_services).

* Google
  * [Geocoding](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/google/geocoder.py)

* Here
  * [Geocoding](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/here/geocoder.py)
  * [Routing](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/here/routing.py)

## How to add a new service

These are the steps that need to be followed when creating a new service in the API or updating an existent one.

### Creating a new service function or editing an existent one
In this scenario, both client and server sides require to be edited/created.

* Update the interface file with the function addition or update
  * Interfaces are stored in `client/renderer/interfaces`
  * Interface YAML filenames follow the client versioning schema with the format `interface-x.y.z.yaml`.

* Update the renderer templates or script, *if applicable*
  * Renderer templates are stored in `client/renderer/templates`
  * The Renderer script (`client/renderer/sql-template-renderer`) generates SQL from the defined interfaces

* Generate a new subfolder version for `sql` and `test` folders to define the new functions and tests
  * TODO: Use symlinks to avoid file duplication between versions that don't update them
  * The `client/sql` folder contents are generated from the interfaces in the first step
  * Add or upgrade your SQL server functions
  * Create tests for the client and server functions -- at least, to check that those are created

* Generate the upgrade and downgrade files for the extension for both client and server

* Update the control files and the Makefiles to generate the complete SQL file for the new created version
  * These new version files (`cdb_dataservices_client--X.Y.Z.sql and cdb_dataservices_server--X.Y.X.sql) must be pushed and frozen. You can add these to the `.gitignore` file.

* Update the public docs! ;-)

### Updating an existing server side function

With no changes in client side.

### Extension

* Generate a new subfolder version for `sql` and `test` folders to define the new functions and tests
  * TODO: Use symlinks to avoid file duplication between versions that don't update them
  * Add or upgrade your SQL server functions
    * For example, if a new street geocoder service is implemented, it will require a change in the main function (`cdb_dataservices_server.cdb_geocode_street_point`) and generate a new `cdb_dataservices_server._cdb_newservice_geocode_street_point`

* Generate the upgrade and downgrade files for the extension for the client

### Python

* Add, if needed, [new configuration elements](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/metrics/config.py#L100)

* Add the new functionality into the provider folder. If the provider is new, create a new folder(`server/lib/python/cartodb_services/cartodb_services/{provider_name}` and add the service (`geocoder.py`)

* Check the `__init__.py` files to follow the existent [import conventions](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/metrics/__init__.py)

* Add a new metric, if needed, at the [corresponding service](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/cartodb_services/metrics/quota.py#L37-L60)

* Update the package version in [setup.py](https://github.com/CartoDB/geocoder-api/blob/983440086d3fabf03aedc66f53dcf4c4a8cb2323/server/lib/python/cartodb_services/setup.py)


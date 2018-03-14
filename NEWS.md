
March 14th, 2018
================
* Version `0.17.3` of the python library
    * Fix bug with Mapbox routing not using the proper quota value

February 22th, 2018
==================
* Version `0.17.2` of the python library
    * Fix bug with Mapbox isolines not stopping at the seacoast

February 27th, 2018
==================
* Version `0.17.1` of the python library
    * Fix bug when the mapzen credentials are not in the db config and we keep getting them

February 22th, 2018
==================
* Version `0.17.0` of the python library
    * Change default provider to Mapbox
    * Remove the obligatory nature of the Mapzen configuration due to its deprecation as provider

February 13th, 2018
==================
* Version `0.16.7` of the python library
    * Pick the first result when Mapbox geocoder returns multiple results #462
    * Normalize input for Mapbox geocoder #462

February 12th, 2018
==================
* Version `0.16.6` of the python library
    * Using Mapbox permanent geocoder #455

February 5th, 2018
==================
* Version `0.16.5` of the python library
    * Fix displaced routing shape #443
    * Check for empty coordinates object before converting it to polygon
    * 422 errors that come from Mapbox now returns an empty result because is a bad input from the user data

February 2th, 2018
==================
* Version `0.16.4` of the python library
    * Create a QuotaExceededException instead of using a generic one
* Version `0.30.2` of server side
    * Return empty value when the quota is exceeded and don't send the exception to external loggers
      to avoid noise

January 31th, 2018
==================
* Version `0.16.3` of the python library
    * Fix for Mapbox geocoder to handle empty requests and empty responses
    * Remove raising an exception when non parameters are passed to the HERE geocoder
    * Fix for HERE geocoder with non empty requests
    * Added more coverage to the google geocoder credentials parse logic

January 29th, 2018
==================
* Version `0.30.1` of server side
    * Fix for Mapbox geocoding function due to the iso3166 library doesn't support UTF-8 names for the countries
* Version `0.16.2` of the python library
    * Fix for Mapbox cycling profile

January 18th, 2018
==================
* Version `0.16.1` of the python library
    * Fixed encoding problem with Mapbox geocoding (using the Mapbox Python library)

January 17th, 2018
==================
* Version `0.16.0` of the python library
    * Added Mapbox provider for routing, geocoding and isolines
* Version `0.30.0` of the server extension
    * Added Mapbox provider for routing, geocoding and isolines
    * Fixed a bug that makes impossible to install server side if the client is already installed due a namespace problem
* Version `0.23.0` of the client
    * Added Mapbox provider for routing, geocoding and isolines

December 1st, 2017
==================
* Version `0.29.0` of the server extension
    * Functions qualified with PARALLEL and volatility
* Version `0.22.0` of the client
    * Functions qualified with PARALLEL and volatility
    * Fixed an issue with upgrades from older versions. See #417

November 17th, 2017
=================
* Version `0.15.6` of the python library
    * Added support for channels for google geocoder #409
    * Improved the way we manage the client_id #409

October 18th, 2017
=================
* Version `0.21.0` of the client extension
    * Added new parameter `number_geometries` to the `obs_getavailablegeometries` to improve the score calculation
* Version `0.28.0` of the server extension
    * Added new parameter `number_geometries` to the `obs_getavailablegeometries` to improve the score calculation

October 6th, 2017
=================
* Version `0.15.5` of the python library
    * googlemaps dependency updated to v2.5.1
    * Google geocoder performance boost: client connections are now reused between queries. See #401
    * Fixed issue with Google keys validity check. See #382
    * Fixed inconsistency in service usage failed requests tracking. See f0a3249
* Client extension tests are now compatible with PostgreSQL 9.5 and 9.6

August 30th, 2017
=============
* Version `0.15.4` of the python library
    * Fixed invalid geometries for isochrones due to `generalize` option. See #397

August 24th, 2017
=============
* Improved the documentation
* Version `0.15.3` of the python library
    * Disabled DO quota check for users that have it configured . See #395

August 23th, 2017
=============
* Version `0.27.0` of the server
    * New public DO function to perform metadata validation, `obs_metadatavalidation`. See #392
* Version `0.20.0` of the client
    * New private function to precheck the DO requests, `_obs_precheck`. See #392
    * New public DO function to perform metadata validation, `obs_metadatavalidation`. See #392

July 20th, 2017
=============
* Version `0.26.0` of the server
    * New private function to be used by the UI, `_obs_getnumerators`. See #386
* Version `0.19.0` of the client
    * New private function to be used by the UI, `_obs_getnumerators`. See #386

July 13th, 2017
=============
* Version `0.25.0` of the server
    * Add postalcode numeric type function. See #387

* Version `0.15.2` of the python library
    * Fixed some test. See #387

* Version `0.18.0` of the client and version `0.25.0` of the server
    * Add postalcode numeric type function. See #387

June 28th, 2017
=============
* Not version specific, content change only
    * Removed link to /docs/faqs and enhanced ZCTA note directly in the Postal Coder docs.

May 26th, 2017
=============
* Version `0.24.2` of the server
    * Fixed fallback logic for namedplaces geocoding functions

* Version `0.15.1` of the python library
    * Fixed some typos and improve exception messages
    * Added a check for the google client credentials in order to improve the error message

May 16th, 2017
=============
* Version `0.24.1` of the server
    * Fixed an interface mismatch between DS API and OBS backend, when returning no data. See #366

May 9th, 2017
=============
* Version `0.17.0` of the client and version `0.24.0` of the server
    * Fixed some missing return values documented but not present.
        *  `OBS_GetAvailableGeometries` now returns `geom_type`, `geom_extra` and `geom_tags` in addition to existing values.
        *  `OBS_GetAvailableTimespans` now returns `timespan_type`, `timespan_extra`, `timespan_tags` in addition to existing values.

March 28th, 2017
================

* Version 0.16.0 of the client, version 0.23.0 of the server and version 0.15.0 of the python library
  * Added support for rate-limiting the geocoding services. See #365

March 13th, 2017
================
* Version `0.14.1` of the python library:
  * Clean up code that reads from non zero padded date keys #206

March 8th, 2017
===============
* Version 0.22.0 of the server and version 0.14.0 of the python library
  * New optional configuration parameters for external services can be provided through `cdb_conf`:
    - In `heremaps_conf`, under `geocoder.service`: `json_url`, `connect_timeout`, `read_timeout`, `max_retries`, `gen`
    - In `heremaps_conf`, under `isolines.service`: `base_url`, `connect_timeout`, `read_timeout`, `max_retries`, `isoline_path`
    - In `mapzen_conf`, under `geocoder.service`: `base_url`, `connect_timeout`, `read_timeout`, `max_retries`
    - In `mapzen_conf`, under `routing.service`: `base_url`, `connect_timeout`, `read_timeout`
    - In `mapzen_conf`, under `matrix.service`: `one_to_many_url`, `connect_timeout`, `read_timeout`
    - In `mapzen_conf`, under `isochrones.service`: `base_url`, `connect_timeout`, `read_timeout`, `max_retries`
  * Strictly speaking, version 0.14.0 of the python library is not compatible with 0.13.0, but the changes are made on method signatures with default values that were not used from the PG extension.
  * Improvements to the Mapzen geocoder client, that should yield better results overall. See #342

February 2st, 2017
===================
* Version 0.21.0 of the server and version 0.15.0 of the client
  * Added functions `OBS_GetData` and `OBS_GetMeta`
  * Default isolines provider changed to `mapzen` instead of `heremaps`

November 29st, 2016
===================
* Version 0.20.0 of the server and version 0.12.0 of the python library
  * Added integration with the new Mapzen isochrones functionality

November 25st, 2016
===================
* Version 0.19.0 of the server, version 0.11.0 of the python library and version 0.13.0 of the client
  * functions to check the quota, both server and client
  * removed the no_params from the templates (this caused trouble, not needed anymore)
  * bug fixes: observatory quota, quotas as integers, mapzen geocoder soft limit as bool

November 21st, 2016
===================
* Version 0.18.1 of the server and version 0.12.1 of the client
  * Add new fields to the obs_meta_geometry due to new changes introduced in the DO 1.1.2 release

November 11st, 2016
===================
* Version 0.18.0 of the server and version 0.12.0 of the client
  * Added obs_legacybuildermetada functions to grab the needed metadata in the builder while making a data enrichment analysis. Closes #286
  * Added metadata functions that will be used in the future to gather the metadata for the new data enrichment UI. Closes #287
  * Fixed integration test for street geocoding
  * Makefile now has a new task to create a new release in the client part, as was in the server, using make release NEW_VERSION=x.x.x

November 7st, 2016
==================
* Version 0.17.0 of the server and version 0.10.0 of the python package
    * Added metrics context manager to gather data from different parts of the server functions
    * Support multiple response data for one server function call: For example in the one_to_many matrix client
    * Metrics files configuration is not mandatory
    * All the services covered and gathering metrics

October 27st, 2016
==================
* Version 0.9.4 of the python package
    * Added timeouts to all the third-party connections using requests because requests by default doesn't add timeouts.

October 26st, 2016
==================
* Version 0.9.3 of the python package
    * Fixes https://github.com/CartoDB/dataservices-api/issues/293
    * Mitigate problem with 504 errors coming from Mapzen

October 21st, 2016
==================
* Version 0.9.2 of the python package
    * mapzen routing quota now is configurable per user

September 28, 2016
==========
* Released version 0.8.1 of Python package cartodb\_services
  * Improvements in QPS retry decorator for requests to external services

https://github.com/CartoDB/dataservices-api/releases/tag/python-0.8.1

September 8, 2016
===========
* Released version 0.11.1 of the client
  * Minor change in the name of the function parameter sent to server and Observatory backend for compatibility with the last observatory-extension framework updates

September 1, 2016
===========
* Released version 0.11.0 of the client
  * Include DS table functions to create and populate a table with the GetMeasure function in observatory
* Released version 0.15.1 of the server
  * Rename DS table functions

August 29, 2016
===========
* Released version 0.15.0 of the server
* Geocode namedplace point functions uses Mapzen search service and in case of error
  it'll use the internal geocoder

August 19, 2016
===========
* Released version 0.7.4.2 of the server python library
* Now connection errors, that intermittently come from Mapzen geocoding service, are caught and treated
* Added more information to the logs from response
* Fixed some errors in the QPS manager when the response object is None

August 11, 2016
===========
* Released server version 0.14.2
* Released client version 0.10.2
* Always default arguments for DO functions to NULL, which prevents duplication & overwrite

August 5, 2016
===========
* Released server version 0.14.1
* Fix problem with calling a logger method that doesn't exists

August 3, 2016
===========
* Released server version 0.14
* New logger with: plpy, rollbar integration and file
* Added min log level to notify as config option
* Server config to define dataservices environment for: log, third party servers, etc
* Added logger to the SQL functions
* Raise exception on events that should not be logged like reach the quota limit

July 28, 2016
===========
* Release server 0.13.3.1
* Fixed limit to 1 row for isolines with multiple range

https://github.com/CartoDB/dataservices-api/releases/tag/0.13.3.1-server

July 25, 2016
===========
* Release client 0.10.1
* Includes an update of the `__AugmentTable` function of the client which creates an index on `cartodb_id` for the temporary table that stores the augmented results that will be afterwards joined with the original table by using this same key, `cartodb_id`.

https://github.com/CartoDB/dataservices-api/releases/tag/0.10.1-client

July 25, 2016
===========
* Release server 0.13.3
* Add provider per service
* Default provider in case the provider is not set
* Refactor and improvements in the multiprovider services functions

https://github.com/CartoDB/dataservices-api/releases/tag/0.13.3-server

July 22, 2016
===========
* Release server 0.13.2
* Fixes bug with multirange isolines #233

https://github.com/CartoDB/dataservices-api/releases/tag/0.13.2-server

July 15, 2016:
===========
* Release server 0.13.1
* Includes a fix for the table augmentation functions in the server, which will now retrieve the client IP address and send it to the observatory functions as a new parameter. The affected functions are:

  * _OBS_ConnectUserTable

  * __OBS_ConnectUserTable

  This change does not require any client change.

 https://github.com/CartoDB/dataservices-api/releases/tag/0.13.1-server

Jul 12, 2016:
===========
* Release server 0.13.0
* [Server] Add beta augment functions, isoline fixes, observatory dump version

https://github.com/CartoDB/dataservices-api/releases/tag/0.13.0-server

Jul 12, 2016:
===========
* Release client 0.10.0
* [Client] Add beta augment functions, isoline fixes, observatory dump version

https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-client

Jul 7, 2016:
===========
* Release client 0.9.0
* This release adds two new functions in the Data Services extension client:
  * cdb_mapzen_isodistance
  * cdb_mapzen_isochrone
  it also includes a bugfix for the previous release in which the explicit GRANTs to the new functions for the here, google and mapzen geocoder providers was missing in the upgrade file.

https://github.com/CartoDB/dataservices-api/releases/tag/0.9.0-client

Jul 7, 2016:
===========
* Release server 0.12.0
* This release adds four new functions in the Data Services extension server:
  * cdb_mapzen_isodistance
  * cdb_mapzen_isochrone
  * _cdb_mapzen_isolines, which contains the real isoline logic.
  * _get_mapzen_isolines_config which retrieves the explicit configuration for the Mapzen matrix service.
* In the Python end, this release adds the new Mapzen Matrix logic as well as the additions in the configuration and metrics file for the new service type mapzen_isolines.

https://github.com/CartoDB/dataservices-api/releases/tag/0.12.0-server

Jul 5, 2016:
===========
* Release server 0.11.0
* Added three new public functions for each geocoding provider:
  * cdb_here_geocode_street_point
  * cdb_google_geocode_street_point
  * cdb_mapzen_geocode_street_point
* Added new function to retrieve specifically Mapzen configuration:
  * _get_mapzen_geocoder_config
  which uses the new class MapzenGeocoderConfig in the Python library.

https://github.com/CartoDB/dataservices-api/releases/tag/0.11.0-server

Jul 5, 2016:
===========
* Release client 0.8.0
* Expose providers in high-precision geocoder functions

https://github.com/CartoDB/dataservices-api/releases/tag/0.8.0-client

Jun 15, 2016:
===========
* [server python] Write quota info from services with zero padding. Closes issue #204.

https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server3

Jun 13, 2016:
===========
* [server python] Read quota info from services with and without zero padding. Closes issue #201.

https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server2

May 31, 2016:
===========
* Release client 0.7.0
* Adds new function OBS_GetMeasureById

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.0-client

May 31, 2016:
===========
* Release server 0.10.0
* Adds new function OBS_GetMeasureById

https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server

May 25, 2016:
===========
* Release server 0.9.0
* Added a new routing function which allows to generate routes from an origin to a destination, which passes through a set of defined locations:

  * cdb_dataservices_server.cdb_route_with_waypoints (username text, organization_name text, waypoints geometry(Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

  * cdb_dataservices_server._cdb_mapzen_route_with_waypoints(waypoints geometry(username text, orgname text, Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

  and updates the old cdb_route_point_to_point function to convert the input origin and destination geometries into an array of geometries.

* Support arrays of geometries as input for the Mapzen routing Python client.

* __parse_directions will now generate the locations JSON for the service from an array of geometries.

https://github.com/CartoDB/dataservices-api/releases/tag/0.9.0-server

May 25, 2016:
===========
* Release client 0.6.0
* Includes new client function to obtain a route with waypoints:
  * cdb_dataservices_client.cdb_route_with_waypoints (waypoints geometry(Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0-client

May 18, 2016:
===========
* Release client 0.5.0
* Added new functions for the data observatory:
  * obs_getdemographicsnapshot(geometry);
  * obs_getsegmentsnapshot(geometry);
  * obs_getboundary(geometry, text);
  * obs_getboundaryid(geometry, text);
  * obs_getboundarybyid(text, text);
  * obs_getboundariesbygeometry(geometry, text);
  * obs_getboundariesbypointandradius(geometry, numeric, text);
  * obs_getpointsbygeometry(geometry, text);
  * obs_getpointsbypointandradius(geometry, numeric, text);
  * obs_getmeasure(geometry, text);
  * obs_getcategory(geometry, text);
  * obs_getuscensusmeasure(geometry, text);
  * obs_getuscensuscategory(geometry, text);
  * obs_getpopulation(geometry);
  * obs_search(text);
  * obs_getavailableboundaries(geometry);

https://github.com/CartoDB/dataservices-api/releases/tag/0.5.0-client

May 18, 2016:
===========
* Release server 0.8.0: Data Observatory release
* Added new functions for the data observatory:
  * obs_getdemographicsnapshot(geometry);
  * obs_getsegmentsnapshot(geometry);
  * obs_getboundary(geometry, text);
  * obs_getboundaryid(geometry, text);
  * obs_getboundarybyid(text, text);
  * obs_getboundariesbygeometry(geometry, text);
  * obs_getboundariesbypointandradius(geometry, numeric, text);
  * obs_getpointsbygeometry(geometry, text);
  * obs_getpointsbypointandradius(geometry, numeric, text);
  * obs_getmeasure(geometry, text);
  * obs_getcategory(geometry, text);
  * obs_getuscensusmeasure(geometry, text);
  * obs_getuscensuscategory(geometry, text);
  * obs_getpopulation(geometry);
  * obs_search(text);
  * obs_getavailableboundaries(geometry);
* Added quota manage for these new functions

https://github.com/CartoDB/dataservices-api/releases/tag/0.8.0-server

May 10, 2016:
===========
* Release server 0.7.4
* In case we receive a 4xx error from one of the services: isolines, here geocoder, etc we have to return an empty value an increment the empty counter. We have to raise exception in 5xx or unhandled exceptions

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.4-server

May 10, 2016:
===========
* Release server 0.7.3
* Change how the blue/green system is working in the server side. Now the loopback is only in the observatory extension functions call instead in all the dataservices-api function for observatory

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.3-server

May 4, 2016:
===========
* Release server 0.7.2
* Added Blue/Green capability to the data observatory functions in order to be able to use staging or production databases

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.2-server

Apr 25, 2016:
===========
* Release server 0.7.1
* Use redis based config if exists, if not use the db config value
* Refactor key to segregate more, now the services is called obs_snapshot

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.1-server

Apr 21, 2016:
===========
* Release client 0.4.0
* Remove old versioning system for client side
* Added obs_get_demography_snapshot function
* Added obs_get_segment snapshot function
* Integrated quota checking

https://github.com/CartoDB/dataservices-api/releases/tag/0.4.0-client

Apr 21, 2016:
===========
* Release server 0.7.0
* Added obs_get_demography_snapshot function
* Added obs_get_segment snapshot function
* Integrated quota checking

https://github.com/CartoDB/dataservices-api/releases/tag/0.7.0-server

Apr 19, 2016:
===========
* Release server 0.6.2
* Add Mapzen routing and geocoder quota check

https://github.com/CartoDB/dataservices-api/releases/tag/0.6.2-server

Apr 14, 2016:
===========
* Release server 0.6.1
* Now the implementation knows how to get the iso3 for the passed country in order to pass it to Mapzen
* The city an the state/province parameters are used for mapzen too

https://github.com/CartoDB/dataservices-api/releases/tag/0.6.1-server

Apr 1, 2016:
===========
* Release server 0.6.0.1
* Use specific isoline routing credentials for a provider for isoline functions, which were previously using the general credentials from the provider.

https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0.1-server

Mar 28, 2016:
===========
* Release server 0.6.0
* Integrated Mapzen geocoder for street level geocoding function

 https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0-server

Mar 23, 2016:
===========
* Release server 0.5.2
* Deleted old versioning system
* 4xx responses returns empty routes despite to raise an exception
* In some cases we return and empty response: one of the inputs is null, there is no generated shape for the route, etc

https://github.com/CartoDB/dataservices-api/releases/tag/0.5.2-server

Mar 17, 2016:
===========
* Release server 0.5.1
* Renamed the python library metrics functions
* Create old version's folder to store the last versions
* Refactor: Move redis and DB config logic to the python library
* Generate the metrics log file

https://github.com/CartoDB/dataservices-api/releases/tag/0.5.1-server

Mar 14, 2016:
===========
* Release server 0.5.0
* Mapzen routing functions to calculate a route point to point
* Use of Sentinel transparently

https://github.com/CartoDB/dataservices-api/releases/tag/0.5.0-server

Mar 14, 2016:
===========
* Release client 0.3.0
* Added cdb_routing_point_to_point function using Mapzen as provider

https://github.com/CartoDB/dataservices-api/releases/tag/0.3.0-client

Feb 26, 2016:
===========
* Release client 0.2.0
* Added routing isolines capabilities to the client and public API

https://github.com/CartoDB/dataservices-api/releases/tag/0.2.0-client

Feb 26, 2016:
===========
* Release server 0.4.0
* Added routing isolines capabilities

https://github.com/CartoDB/dataservices-api/releases/tag/0.4.0-server

Feb 11, 2016:
===========
* Release server 0.3.0
* Extension refactor, now is called cdb_dataservices_[client|server] in order to include more services aside the geocoder.
* Add logic to save the metrics for the internal geocoder services as we have for the nokia and google geocoders
* Trimmed all the inputs to avoid empty results

https://github.com/CartoDB/dataservices-api/releases/tag/0.3.0-server

Feb 4, 2016:
===========
* Release server 0.2.0
* Logic for the google geocoder so the users with this geocoder set up can use street level geocoding too
* Refactor of the python library in order to reflect the change to a services extension more than only geocoder

https://github.com/CartoDB/dataservices-api/releases/tag/0.2.0-server

Jan 25, 2016:
===========
* Release Geocoder API 0.1.0
* Street geocoding available through the cdb_geocoder_street_point_v2 function (only working Heremaps geocoder)
* User config comes from Redis database
* Increment of usage metrics for the cdb_geocoder_street_v2

https://github.com/CartoDB/dataservices-api/releases/tag/0.1.0

Jan 25, 2016:
===========
* Release Geocoder API 0.0.1 production ready

https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1

Dec 23, 2015:
===========
* Release Geocoder API 0.0.2 beta

https://github.com/CartoDB/dataservices-api/releases/tag/0.0.2

Dec 3, 2015:
===========
* Release Geocoder API 0.0.1 Beta2

https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1-beta2

Nov 27, 2015:
===========
* Release Geocoder API BETA 1
  * Added the organization public user to the api key check

https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1-beta

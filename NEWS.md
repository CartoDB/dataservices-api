[...]


Jul 12, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.13.0-server
===========
* Release server 0.13.0
* [Server] Add beta augment functions, isoline fixes, observatory dump version

Jul 12, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-client
===========
* Release client 0.10.0
* [Client] Add beta augment functions, isoline fixes, observatory dump version

Jul 7, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.9.0-client
===========
* Release client 0.9.0
* This release adds two new functions in the Data Services extension client:
  * cdb_mapzen_isodistance
  * cdb_mapzen_isochrone
  it also includes a bugfix for the previous release in which the explicit GRANTs to the new functions for the here, google and mapzen geocoder providers was missing in the upgrade file.

Jul 7, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.12.0-server
===========
* Release server 0.12.0
* This release adds four new functions in the Data Services extension server:
  * cdb_mapzen_isodistance
  * cdb_mapzen_isochrone
  * _cdb_mapzen_isolines, which contains the real isoline logic.
  * _get_mapzen_isolines_config which retrieves the explicit configuration for the Mapzen matrix service.
* In the Python end, this release adds the new Mapzen Matrix logic as well as the additions in the configuration and metrics file for the new service type mapzen_isolines.

Jul 5, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.11.0-server
===========
* Release server 0.11.0
* Added three new public functions for each geocoding provider:
  * cdb_here_geocode_street_point
  * cdb_google_geocode_street_point
  * cdb_mapzen_geocode_street_point
* Added new function to retrieve specifically Mapzen configuration:
  * _get_mapzen_geocoder_config
  which uses the new class MapzenGeocoderConfig in the Python library.

Jul 5, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.8.0-client
===========
* Release client 0.8.0
* Expose providers in high-precision geocoder functions

Jun 15, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server3
===========
* [server python] Write quota info from services with zero padding. Closes issue #204.

Jun 13, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server2
===========
* [server python] Read quota info from services with and without zero padding. Closes issue #201.

May 31, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.0-client
===========
* Release client 0.7.0
* Adds new function OBS_GetMeasureById

May 31, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.10.0-server
===========
* Release server 0.10.0
* Adds new function OBS_GetMeasureById

May 25, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.9.0-server
===========
* Release server 0.9.0
* Added a new routing function which allows to generate routes from an origin to a destination, which passes through a set of defined locations:

  * cdb_dataservices_server.cdb_route_with_waypoints (username text, organization_name text, waypoints geometry(Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

  * cdb_dataservices_server._cdb_mapzen_route_with_waypoints(waypoints geometry(username text, orgname text, Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

  and updates the old cdb_route_point_to_point function to convert the input origin and destination geometries into an array of geometries.

* Support arrays of geometries as input for the Mapzen routing Python client.

__parse_directions will now generate the locations JSON for the service from an array of geometries.

May 25, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0-client
===========
* Release client 0.6.0
* Includes new client function to obtain a route with waypoints:
  * cdb_dataservices_client.cdb_route_with_waypoints (waypoints geometry(Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')

May 18, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.5.0-client
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

May 18, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.8.0-server
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

May 10, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.4-server
===========
* Release server 0.7.4
* In case we receive a 4xx error from one of the services: isolines, here geocoder, etc we have to return an empty value an increment the empty counter. We have to raise exception in 5xx or unhandled exceptions

May 10, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.3-server
===========
* Release server 0.7.3
* Change how the blue/green system is working in the server side. Now the loopback is only in the observatory extension functions call instead in all the dataservices-api function for observatory

May 4, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.2-server
===========
* Release server 0.7.2
* Added Blue/Green capability to the data observatory functions in order to be able to use staging or production databases

Apr 25, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.1-server
===========
* Release server 0.7.1
* Use redis based config if exists, if not use the db config value
* Refactor key to segregate more, now the services is called obs_snapshot

Apr 21, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.4.0-client
===========
* Release client 0.4.0
* Remove old versioning system for client side
* Added obs_get_demography_snapshot function
* Added obs_get_segment snapshot function
* Integrated quota checking

Apr 21, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.7.0-server
===========
* Release server 0.7.0
* Added obs_get_demography_snapshot function
* Added obs_get_segment snapshot function
* Integrated quota checking

Apr 19, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.6.2-server
===========
* Release server 0.6.2
* Add Mapzen routing and geocoder quota check


Apr 14, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.6.1-server
===========
* Release server 0.6.1
* Now the implementation knows how to get the iso3 for the passed country in order to pass it to Mapzen
* The city an the state/province parameters are used for mapzen too

Apr 1, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0.1-server
===========
* Release server 0.6.0.1
* Use specific isoline routing credentials for a provider for isoline functions, which were previously using the general credentials from the provider.

Mar 28, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.6.0-server
===========
* Release server 0.6.0
* Integrated Mapzen geocoder for street level geocoding function

Mar 23, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.5.2-server
===========
* Release server 0.5.2
* Deleted old versioning system
* 4xx responses returns empty routes despite to raise an exception
* In some cases we return and empty response: one of the inputs is null, there is no generated shape for the route, etc

Mar 17, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.5.1-server
===========
* Release server 0.5.1
* Renamed the python library metrics functions
* Create old version's folder to store the last versions
* Refactor: Move redis and DB config logic to the python library
* Generate the metrics log file

Mar 14, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.5.0-server
===========
* Release server 0.5.0
* Mapzen routing functions to calculate a route point to point
* Use of Sentinel transparently

Mar 14, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.3.0-client
===========
* Release client 0.3.0
* Added cdb_routing_point_to_point function using Mapzen as provider

Feb 26, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.2.0-client
===========
* Release client 0.2.0
* Added routing isolines capabilities to the client and public API

Feb 26, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.4.0-server
===========
* Release server 0.4.0
* Added routing isolines capabilities

Feb 11, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.3.0-server
===========
* Release server 0.3.0
* Extension refactor, now is called cdb_dataservices_[client|server] in order to include more services aside the geocoder.
* Add logic to save the metrics for the internal geocoder services as we have for the nokia and google geocoders
* Trimmed all the inputs to avoid empty results

Feb 4, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.2.0-server
===========
* Release server 0.2.0
* Logic for the google geocoder so the users with this geocoder setted up can use street level geocoding too
* Refactor of the python library in order to reflect the change to a services extension more than only geocoder

Jan 25, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.1.0
===========
* Release Geocoder API 0.1.0
* Street geocoding available through the cdb_geocoder_street_point_v2 function (only working Heremaps geocoder)
* User config comes from Redis database
* Increment of usage metrics for the cdb_geocoder_street_v2

Jan 25, 2016: https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1
===========
* Release Geocoder API 0.0.1 production ready

Dec 23, 2015: https://github.com/CartoDB/dataservices-api/releases/tag/0.0.2
===========
* Release Geocoder API 0.0.2 beta

Dec 3, 2015: https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1-beta2
===========
* Release Geocoder API 0.0.1 Beta2

Nov 27, 2015: https://github.com/CartoDB/dataservices-api/releases/tag/0.0.1-beta
===========
* Release Geocoder API BETA 1 
  * Added the organization public user to the api key check

\set VERBOSITY terse
-- Use regular user role
SET ROLE test_regular_user;

-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Check the regular user has no permissions on private functions
SELECT _cdb_geocode_admin0_polygon('evil_user', 'evil_orgname', 'Hell');
SELECT _cdb_geocode_admin1_polygon('evil_user', 'evil_orgname', 'Hell');
SELECT _cdb_geocode_admin1_polygon('evil_user', 'evil_orgname', 'Sheol', 'Hell');
SELECT _cdb_geocode_namedplace_point('evil_user', 'evil_orgname', 'Sheol');
SELECT _cdb_geocode_namedplace_point('evil_user', 'evil_orgname', 'Sheol', 'Hell');
SELECT _cdb_geocode_namedplace_point('evil_user', 'evil_orgname', 'Sheol', 'Hell', 'Ugly world');
SELECT _cdb_geocode_postalcode_polygon('evil_user', 'evil_orgname', '66666', 'Hell');
SELECT _cdb_geocode_postalcode_point('evil_user', 'evil_orgname', '66666', 'Hell');
SELECT _cdb_geocode_ipaddress_point('evil_user', 'evil_orgname', '8.8.8.8');
SELECT _cdb_geocode_street_point('evil_user', 'evil_orgname', 'one street, 1');
SELECT _cdb_route_point_to_point('evil_user', 'evil_orgname', 'POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');

-- -- Exercise the public function
-- -- it is public, it shall work
-- No permissions granted
SELECT cdb_geocode_admin0_polygon('Spain');
SELECT cdb_geocode_admin1_polygon('California');
SELECT cdb_geocode_admin1_polygon('California', 'United States');
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');
SELECT cdb_geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocode_postalcode_point('03204', 'Spain');
SELECT cdb_geocode_ipaddress_point('8.8.8.8');
SELECT cdb_geocode_street_point('one street, 1');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');

-- Grant other permissions but geocoding and routing
SET ROLE postgres;
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["isolines"]}');
SET ROLE test_regular_user; -- Use regular user role
SELECT cdb_geocode_admin0_polygon('Spain');
SELECT cdb_geocode_admin1_polygon('California');
SELECT cdb_geocode_admin1_polygon('California', 'United States');
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');
SELECT cdb_geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocode_postalcode_point('03204', 'Spain');
SELECT cdb_geocode_ipaddress_point('8.8.8.8');
SELECT cdb_geocode_street_point('one street, 1');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');

-- Grant geocoding permissions
SET ROLE postgres;
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["geocoding", "routing"]}');
SET ROLE test_regular_user; -- Use regular user role
SELECT cdb_geocode_admin0_polygon('Spain');
SELECT cdb_geocode_admin1_polygon('California');
SELECT cdb_geocode_admin1_polygon('California', 'United States');
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');
SELECT cdb_geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocode_postalcode_point('03204', 'Spain');
SELECT cdb_geocode_ipaddress_point('8.8.8.8');
SELECT cdb_geocode_street_point('one street, 1');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');

-- Remove permissions
SET ROLE postgres;
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

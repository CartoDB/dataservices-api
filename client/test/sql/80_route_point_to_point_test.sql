\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_point_to_point (username text, orgname text, origin geometry(Point, 4326), destination geometry(Point, 4326), mode TEXT, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE 
  ret cdb_dataservices_client.simple_route;
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_route_point_to_point invoked with params (%, %, %, %, %, %, %)', username, orgname, origin, destination, mode, options, units;
  SELECT NULL, 5.33, 100 INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_route_with_waypoints(username text, orgname text, waypoints geometry(Point, 4326)[], mode TEXT, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE 
  ret cdb_dataservices_client.simple_route;
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_route_with_waypoints invoked with params (%, %, %, %, %, %)', username, orgname, waypoints, mode, options, units;
  SELECT NULL, 2.22, 500 INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql';


-- -- Exercise the public and the proxied function

-- No permissions granted
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY[]::text[], 'miles');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY[]::text[], 'miles');

-- Grant other permissions but routing
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["geocoding", "isolines"]}');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY[]::text[], 'miles');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY[]::text[], 'miles');

-- Grant routing permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["routing"]}');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car');
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_point_to_point('POINT(-87.81406 41.89308)'::geometry,'POINT(-87.79209 41.86138)'::geometry, 'car', ARRAY[]::text[], 'miles');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car');
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY['mode_type=shortest']::text[]);
SELECT cdb_route_with_waypoints(Array['POINT(-87.81406 41.89308)'::geometry,'POINT(-87.80406 41.87308)'::geometry,'POINT(-87.79209 41.86138)'::geometry], 'car', ARRAY[]::text[], 'miles');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

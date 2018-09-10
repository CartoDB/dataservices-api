\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server function
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_admin0_polygon(username text, orgname text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_admin0_polygon invoked with params (%, %, %)', username, orgname, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- -- Exercise the public and the proxied function

-- No permissions granted
SELECT cdb_geocode_admin0_polygon('Spain');

-- Grant other permissions but geocoding
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["routing", "isolines"]}');
SELECT cdb_geocode_admin0_polygon('Spain');

-- Grant geocoding permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["geocoding"]}');
SELECT cdb_geocode_admin0_polygon('Spain');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

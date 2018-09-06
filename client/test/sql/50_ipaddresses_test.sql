\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, appname text, ip_address text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_ipaddress_point invoked with params (%, %, %, %)', username, orgname, appname, ip_address;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- -- Exercise the public and the proxied function

-- No permissions granted
SELECT cdb_geocode_ipaddress_point('8.8.8.8');

-- Grant other permissions but geocoding
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["routing", "isolines"]}');
SELECT cdb_geocode_ipaddress_point('8.8.8.8');

-- Grant geocoding permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["geocoding"]}');
SELECT cdb_geocode_ipaddress_point('8.8.8.8');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

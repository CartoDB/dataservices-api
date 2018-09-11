\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_geocoder_street_point invoked with params (%, %, %, %, %, %)', username, orgname, searchtext, city, state_province, country;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- -- Exercise the public and the proxied function

-- No permissions granted
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');

-- Grant other permissions but geocoding
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"username": "test_user", "permissions": ["routing", "isolines"]}');
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');

-- Grant geocoding permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"username": "test_user", "permissions": ["geocoding"]}');
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');
SELECT cdb_geocode_street_point('One street, 1');
SELECT cdb_geocode_street_point('One street', 'city');
SELECT cdb_geocode_street_point('One street', 'city', 'state');
SELECT cdb_geocode_street_point('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point('One street', 'city', NULL, 'country');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');
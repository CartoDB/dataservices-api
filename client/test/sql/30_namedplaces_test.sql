\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_namedplace_point invoked with params (%, %, %)', username, orgname, city_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_namedplace_point invoked with params (%, %, %, %)', username, orgname, city_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_namedplace_point(username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_namedplace_point invoked with params (%, %, %, %, %)', username, orgname, city_name, admin1_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- -- Exercise the public and the proxied function

-- No permissions granted
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Spain');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');

-- Grant other permissions but geocoding
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["routing", "isolines"]}');
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Spain');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');

-- Grant geocoding permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"application": "testing_app", "permissions": ["geocoding"]}');
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Spain');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

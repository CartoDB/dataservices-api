-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_geocoder_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.cdb_geocode_street_point_v2 (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.cdb_geocode_geocoder_street_point_v2 invoked with params (%, %, %, %, %, %)', username, orgname, searchtext, city, state_province, country;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocode_street_point_v2('One street, 1');
SELECT cdb_geocode_street_point_v2('One street', 'city');
SELECT cdb_geocode_street_point_v2('One street', 'city', 'state');
SELECT cdb_geocode_street_point_v2('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point_v2('One street', 'city', NULL, 'country');
SELECT cdb_geocode_street_point_v2('One street, 1');
SELECT cdb_geocode_street_point_v2('One street', 'city');
SELECT cdb_geocode_street_point_v2('One street', 'city', 'state');
SELECT cdb_geocode_street_point_v2('One street', 'city', 'state', 'country');
SELECT cdb_geocode_street_point_v2('One street', 'city', NULL, 'country');
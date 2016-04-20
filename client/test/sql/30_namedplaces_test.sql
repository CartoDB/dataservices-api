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

-- Exercise the public and the proxied function
SELECT cdb_geocode_namedplace_point('Elx');
SELECT cdb_geocode_namedplace_point('Elx', 'Spain');
SELECT cdb_geocode_namedplace_point('Elx', 'Valencia', 'Spain');


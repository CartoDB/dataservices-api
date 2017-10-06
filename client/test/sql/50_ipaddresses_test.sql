\set VERBOSITY terse
-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_ipaddress_point(username text, orgname text, ip_address text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.cdb_geocode_ipaddress_point invoked with params (%, %, %)', username, orgname, ip_address;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocode_ipaddress_point('8.8.8.8');

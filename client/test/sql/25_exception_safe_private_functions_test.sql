SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server function to fail
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
BEGIN
  RAISE EXCEPTION 'Not enough quota or any other exception whatsoever.';
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Use regular user role
SET ROLE test_regular_user;

-- Exercise the public and the proxied function
SELECT _cdb_geocode_street_point_exception_safe('One street, 1');

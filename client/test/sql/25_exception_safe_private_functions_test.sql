SET client_min_messages TO warning;
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions to raise exceptions
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
BEGIN
  RAISE EXCEPTION 'Not enough quota or any other exception whatsoever.';
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_isodistance(username text, orgname text, source geometry, mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF isoline AS $$
BEGIN
  RAISE EXCEPTION 'Not enough quota or any other exception whatsoever.';
END;
$$ LANGUAGE 'plpgsql';


-- Use regular user role
SET ROLE test_regular_user;

-- Exercise the exception safe and the proxied functions
SELECT _cdb_geocode_street_point_exception_safe('One street, 1');
SELECT the_geom FROM _cdb_isodistance_exception_safe('POINT(-3.70568 40.42028)'::geometry, 'walk', ARRAY[300]::integer[]);

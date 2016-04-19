CREATE TYPE cdb_dataservices_client.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_route_point_to_point (origin geometry(Point, 4326), destination geometry(Point, 4326), mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
  username text;
  orgname text;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;
  
    SELECT * FROM cdb_dataservices_client._cdb_route_point_to_point(username, orgname, origin, destination, mode, options, units) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_point_to_point (username text, organization_name text, origin geometry(Point, 4326), destination geometry(Point, 4326), mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_route_point_to_point (username, organization_name, origin, destination, mode, options, units);
  
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_route_point_to_point(origin geometry(Point, 4326), destination geometry(Point, 4326), mode text, options text[], units text) TO publicuser;

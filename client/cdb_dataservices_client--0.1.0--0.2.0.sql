CREATE TYPE cdb_dataservices_client.isoline AS (
    center geometry(Geometry,4326),
    data_range integer,
    the_geom geometry(Multipolygon,4326)
);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_isodistance (source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
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
  RETURN QUERY
  SELECT * FROM cdb_dataservices_client._cdb_isodistance(username, orgname, source, mode, range, options);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isodistance (username text, organization_name text, source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  SELECT * FROM cdb_dataservices_server.cdb_isodistance (username, organization_name, source, mode, range, options);
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_isodistance(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_isochrone (source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
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

  RETURN QUERY
  SELECT * FROM cdb_dataservices_client._cdb_isochrone(username, orgname, source, mode, range, options);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isochrone (username text, organization_name text, source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  SELECT cdb_dataservices_server.cdb_isochrone (username, organization_name, source, mode, range, options);
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_isochrone(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;

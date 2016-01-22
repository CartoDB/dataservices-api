CREATE OR REPLACE FUNCTION cdb_geocoder_client.cdb_geocode_street_point_v2 (searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
  username text;
  orgname text;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_geocoder_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;
  SELECT cdb_geocoder_client._cdb_geocode_street_point_v2(username, orgname, searchtext, city, state_province, country) INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_geocode_street_point_v2 (username text, organization_name text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.cdb_geocode_street_point_v2 (username, organization_name, searchtext, city, state_province, country);
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_geocoder_client.cdb_geocode_street_point_v2(searchtext text, city text, state_province text, country text) TO publicuser;
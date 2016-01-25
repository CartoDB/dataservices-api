--
-- Get entity config function
--
-- The purpose of this function is to retrieve the username and organization name from
-- a) schema where he/her is the owner in case is an organization user
-- b) entity_name from the cdb_conf database in case is a non organization user
CREATE OR REPLACE FUNCTION cdb_geocoder_client._cdb_entity_config()
RETURNS record AS $$
DECLARE
    result cdb_geocoder_client._entity_config;
    is_organization boolean;
    username text;
    organization_name text;
BEGIN
    SELECT cartodb.cdb_conf_getconf('user_config')->'is_organization' INTO is_organization;
    IF is_organization IS NULL THEN
        RAISE EXCEPTION 'User must have user configuration in the config table';
    ELSIF is_organization = TRUE THEN
        SELECT nspname
        FROM pg_namespace s
        LEFT JOIN pg_roles r ON s.nspowner = r.oid
        WHERE r.rolname = session_user INTO username;
        SELECT cartodb.cdb_conf_getconf('user_config')->>'entity_name' INTO organization_name;
    ELSE
        SELECT cartodb.cdb_conf_getconf('user_config')->>'entity_name' INTO username;
        organization_name = NULL;
    END IF;
    result.username = username;
    result.organization_name = organization_name;
    RETURN result;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

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
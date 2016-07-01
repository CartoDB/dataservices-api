--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.7.0'" to load this file. \quit

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeasurebyid (geom_ref text, measure_id text, boundary_id text, time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
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
  
    SELECT cdb_dataservices_client._obs_getmeasurebyid(username, orgname, geom_ref, measure_id, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasurebyid (username text, organization_name text, geom_ref text, measure_id text, boundary_id text, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getmeasurebyid (username, organization_name, geom_ref, measure_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getmeasurebyid(geom_ref text, measure_id text, boundary_id text, time_span text) TO publicuser;
--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.12.1'" to load this file. \quit

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_dumpversion ()
RETURNS text AS $$
DECLARE
  ret text;
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

    SELECT * FROM cdb_dataservices_client._obs_dumpversion(username, orgname) INTO ret;
    RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_dumpversion (username text, organization_name text)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT * FROM cdb_dataservices_server.obs_dumpversion (username, organization_name);
$$ LANGUAGE plproxy;


DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_enough_quota (username text, organization_name text, service TEXT, input_size NUMERIC);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info (username text, organization_name text);

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_quota_info ();

DROP TYPE IF EXISTS cdb_dataservices_client.service_quota_info;

DROP TYPE IF EXISTS cdb_dataservices_client.service_type;

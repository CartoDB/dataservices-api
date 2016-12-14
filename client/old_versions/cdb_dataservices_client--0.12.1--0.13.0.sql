--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.13.0'" to load this file. \quit

-- Added for consistency (SELECT func instead of SELECT * FROM)
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
  
    SELECT cdb_dataservices_client._obs_dumpversion(username, orgname) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_dumpversion (username text, organization_name text)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_dumpversion (username, organization_name);
  
$$ LANGUAGE plproxy;


-- For quotas and services configuration
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing',
    'observatory'
);

CREATE TYPE cdb_dataservices_client.service_quota_info AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT
);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_quota_info ()
RETURNS SETOF service_quota_info AS $$
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
    SELECT * FROM cdb_dataservices_client._cdb_service_quota_info(username, orgname);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN AS $$
DECLARE
  ret BOOLEAN;
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
  
    SELECT cdb_dataservices_client._cdb_enough_quota(username, orgname, service, input_size) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info (username text, organization_name text)
RETURNS SETOF service_quota_info AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_service_quota_info (username, organization_name);
  
$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_enough_quota (username text, organization_name text, service TEXT, input_size NUMERIC)
RETURNS BOOLEAN AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_enough_quota (username, organization_name, service, input_size);
  
$$ LANGUAGE plproxy;


GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_quota_info() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_enough_quota(service TEXT, input_size NUMERIC) TO publicuser;

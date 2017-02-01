--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.15.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdata (geomvals geomval[] ,params json ,merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomvals, params, merge);

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdata (geomrefs text[] ,params json)
RETURNS TABLE(id text, data json) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomrefs, params);

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeta (geom_ref Geometry(Geometry, 4326) ,params json ,max_timespan_rank integer DEFAULT NULL ,max_score_rank integer DEFAULT NULL ,target_geoms integer DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
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

    SELECT cdb_dataservices_client._obs_getmeta(username, orgname, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms) INTO ret;
    RETURN ret;

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata_exception_safe (geomvals geomval[] ,params json ,merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
DECLARE

  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


    BEGIN
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomvals, params, merge);
    EXCEPTION
      WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
    END;

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata_exception_safe (geomrefs text[] ,params json)
RETURNS TABLE(id text, data json) AS $$
DECLARE

  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


    BEGIN
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomrefs, params);
    EXCEPTION
      WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
    END;

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeta_exception_safe (geom_ref Geometry(Geometry, 4326) ,params json ,max_timespan_rank integer DEFAULT NULL ,max_score_rank integer DEFAULT NULL ,target_geoms integer DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


    BEGIN
      SELECT cdb_dataservices_client._obs_getmeta(username, orgname, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms) INTO ret;
      RETURN ret;
    EXCEPTION
      WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        RETURN ret;
    END;

END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata (username text, organization_name text, geomvals geomval[], params json, merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT * FROM cdb_dataservices_server.obs_getdata (username, organization_name, geomvals, params, merge);

$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata (username text, organization_name text, geomrefs text[], params json)
RETURNS TABLE(id text, data json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT * FROM cdb_dataservices_server.obs_getdata (username, organization_name, geomrefs, params);

$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeta (username text, organization_name text, geom_ref Geometry(Geometry, 4326), params json, max_timespan_rank integer DEFAULT NULL, max_score_rank integer DEFAULT NULL, target_geoms integer DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT cdb_dataservices_server.obs_getmeta (username, organization_name, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms);

$$ LANGUAGE plproxy;
--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.16.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_get_rate_limit (service text)
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

  SELECT cdb_dataservices_client._cdb_service_get_rate_limit(username, orgname, service) INTO ret; RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_set_user_rate_limit (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_user_rate_limit(username, orgname, service, rate_limit);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_set_org_rate_limit (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_org_rate_limit(username, orgname, service, rate_limit);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_set_server_rate_limit (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_server_rate_limit(username, orgname, service, rate_limit);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit_exception_safe (service text)
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
    SELECT cdb_dataservices_client._cdb_service_get_rate_limit(username, orgname, service) INTO ret; RETURN ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_user_rate_limit_exception_safe (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


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
    PERFORM cdb_dataservices_client._cdb_service_set_user_rate_limit(username, orgname, service, rate_limit);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_org_rate_limit_exception_safe (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


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
    PERFORM cdb_dataservices_client._cdb_service_set_org_rate_limit(username, orgname, service, rate_limit);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_server_rate_limit_exception_safe (username text ,orgname text ,service text ,rate_limit json)
RETURNS void AS $$
DECLARE


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
    PERFORM cdb_dataservices_client._cdb_service_set_server_rate_limit(username, orgname, service, rate_limit);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;

  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit (username text, orgname text, service text)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT cdb_dataservices_server.cdb_service_get_rate_limit (username, orgname, service);

$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_user_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT cdb_dataservices_server.cdb_service_set_user_rate_limit (username, orgname, service, rate_limit);

$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_org_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT cdb_dataservices_server.cdb_service_set_org_rate_limit (username, orgname, service, rate_limit);

$$ LANGUAGE plproxy;
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_server_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT cdb_dataservices_server.cdb_service_set_server_rate_limit (username, orgname, service, rate_limit);

$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_get_rate_limit(service text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit_exception_safe(service text )  TO publicuser;

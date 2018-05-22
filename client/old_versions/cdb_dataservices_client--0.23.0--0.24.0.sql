--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.24.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
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

  SELECT cdb_dataservices_client._cdb_tomtom_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_isochrone (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isochrone(username, orgname, source, mode, range, options);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_isodistance (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isodistance(username, orgname, source, mode, range, options);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
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
    SELECT cdb_dataservices_client._cdb_tomtom_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isochrone(username, orgname, source, mode, range, options);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        
  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isodistance(username, orgname, source, mode, range, options);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        
  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_tomtom_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_isochrone (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_tomtom_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_isodistance (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance (username text, orgname text, source geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_tomtom_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_isochrone(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_isodistance(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

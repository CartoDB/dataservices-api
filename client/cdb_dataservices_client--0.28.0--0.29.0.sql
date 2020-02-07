--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.29.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapbox_iso_isochrone (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'isolines' THEN
    RAISE EXCEPTION 'Isolines permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_iso_isochrone(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;


CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapbox_iso_isodistance (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'isolines' THEN
    RAISE EXCEPTION 'Isolines permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_iso_isodistance(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isochrone_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'isolines' THEN
    RAISE EXCEPTION 'Isolines permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_iso_isochrone(username, orgname, source, mode, range, options);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isodistance_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'isolines' THEN
    RAISE EXCEPTION 'Isolines permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_iso_isodistance(username, orgname, source, mode, range, options);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;


DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapbox_iso_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;


DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_iso_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapbox_iso_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;


GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapbox_iso_isochrone(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isochrone_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;


GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapbox_iso_isodistance(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapbox_iso_isodistance_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

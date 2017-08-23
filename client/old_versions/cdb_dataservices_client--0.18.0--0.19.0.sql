--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.19.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getnumerators (bounds geometry(Geometry, 4326) DEFAULT NULL ,section_tags text[] DEFAULT ARRAY[]::TEXT[] ,subsection_tags text[] DEFAULT ARRAY[]::TEXT[] ,other_tags text[] DEFAULT ARRAY[]::TEXT[] ,ids text[] DEFAULT ARRAY[]::TEXT[] ,name text DEFAULT NULL ,denom_id text DEFAULT '' ,geom_id text DEFAULT '' ,timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client.__obs_getnumerators(username, orgname, bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__obs_getnumerators_exception_safe (bounds geometry(Geometry, 4326) DEFAULT NULL ,section_tags text[] DEFAULT ARRAY[]::TEXT[] ,subsection_tags text[] DEFAULT ARRAY[]::TEXT[] ,other_tags text[] DEFAULT ARRAY[]::TEXT[] ,ids text[] DEFAULT ARRAY[]::TEXT[] ,name text DEFAULT NULL ,denom_id text DEFAULT '' ,geom_id text DEFAULT '' ,timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client.__obs_getnumerators(username, orgname, bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;

  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__obs_getnumerators (username text, orgname text, bounds geometry(Geometry, 4326) DEFAULT NULL, section_tags text[] DEFAULT ARRAY[]::TEXT[], subsection_tags text[] DEFAULT ARRAY[]::TEXT[], other_tags text[] DEFAULT ARRAY[]::TEXT[], ids text[] DEFAULT ARRAY[]::TEXT[], name text DEFAULT NULL, denom_id text DEFAULT '', geom_id text DEFAULT '', timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();

  SELECT * FROM cdb_dataservices_server._obs_getnumerators (username, orgname, bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);

$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getnumerators(bounds geometry(Geometry, 4326), section_tags text[], subsection_tags text[], other_tags text[], ids text[], name text, denom_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.__obs_getnumerators_exception_safe(bounds geometry(Geometry, 4326), section_tags text[], subsection_tags text[], other_tags text[], ids text[], name text, denom_id text, geom_id text, timespan text )  TO publicuser;

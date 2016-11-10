--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.12.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE TYPE cdb_dataservices_client.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);

CREATE TYPE cdb_dataservices_client.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);

CREATE TYPE cdb_dataservices_client.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, valid_numer boolean, valid_denom boolean, valid_timespan boolean);

CREATE TYPE cdb_dataservices_client.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, valid_numer boolean, valid_denom boolean, valid_geom boolean);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailablenumerators (bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)
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
  
    RETURN QUERY
    SELECT * FROM cdb_dataservices_client._obs_getavailablenumerators(username, orgname, bounds, filter_tags, denom_id, geom_id, timespan);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailabledenominators (bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getavailabledenominators(username, orgname, bounds, filter_tags, numer_id, geom_id, timespan);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailablegeometries (bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getavailablegeometries(username, orgname, bounds, filter_tags, numer_id, denom_id, timespan);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailabletimespans (bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getavailabletimespans(username, orgname, bounds, filter_tags, numer_id, denom_id, geom_id);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_legacybuildermetadata (aggregate_type text DEFAULT NULL)
RETURNS TABLE(name text, subsection json) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_legacybuildermetadata(username, orgname, aggregate_type);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablenumerators (username text, organization_name text, bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailablenumerators (username, organization_name, bounds, filter_tags, denom_id, geom_id, timespan);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabledenominators (username text, organization_name text, bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)

RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailabledenominators (username, organization_name, bounds, filter_tags, numer_id, geom_id, timespan);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablegeometries (username text, organization_name text, bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, timespan text DEFAULT NULL)

RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailablegeometries (username, organization_name, bounds, filter_tags, numer_id, denom_id, timespan);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabletimespans (username text, organization_name text, bounds geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL)

RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailabletimespans (username, organization_name, bounds, filter_tags, numer_id, denom_id, geom_id);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_legacybuildermetadata (username text, organization_name text, aggregate_type text DEFAULT NULL)

RETURNS TABLE(name text, subsection json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_legacybuildermetadata (username, organization_name, aggregate_type);
  
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailablenumerators(bounds geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailabledenominators(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailablegeometries(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailabletimespans(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_legacybuildermetadata(aggregate_type text) TO publicuser;

--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.8.0'" to load this file. \quit

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_here_geocode_street_point (searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._cdb_here_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_google_geocode_street_point (searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._cdb_google_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapzen_geocode_street_point (searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._cdb_mapzen_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point (username text, organization_name text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_here_geocode_street_point (username, organization_name, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point (username text, organization_name text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_google_geocode_street_point (username, organization_name, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point (username text, organization_name text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_mapzen_geocode_street_point (username, organization_name, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy;

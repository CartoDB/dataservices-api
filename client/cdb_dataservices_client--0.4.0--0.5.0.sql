--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.5.0'" to load this file. \quit

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdemographicsnapshot (geom geometry(Geometry, 4326), time_span text DEFAULT NULL, geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getdemographicsnapshot(username, orgname, geom, time_span, geometry_level);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getsegmentsnapshot (geom geometry(Geometry, 4326), geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getsegmentsnapshot(username, orgname, geom, geometry_level);
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundary (geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getboundary(username, orgname, geom, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundaryid (geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getboundaryid(username, orgname, geom, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundarybyid (geometry_id text, boundary_id text, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getboundarybyid(username, orgname, geometry_id, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundariesbygeometry (geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getboundariesbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundariesbypointandradius (geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getboundariesbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpointsbygeometry (geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getpointsbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpointsbypointandradius (geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getpointsbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeasure (geom Geometry, measure_id text, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getmeasure(username, orgname, geom, measure_id, normalize, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getcategory (geom Geometry, category_id text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getcategory(username, orgname, geom, category_id, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getuscensusmeasure (geom Geometry, name text, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getuscensusmeasure(username, orgname, geom, name, normalize, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getuscensuscategory (geom Geometry, name text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getuscensuscategory(username, orgname, geom, name, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpopulation (geom Geometry, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
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
  
    SELECT cdb_dataservices_client._obs_getpopulation(username, orgname, geom, normalize, boundary_id, time_span) INTO ret;
    RETURN ret;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_search (search_term text, relevant_boundary text DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_search(username, orgname, search_term, relevant_boundary) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailableboundaries (geom Geometry, timespan text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
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
    SELECT * FROM cdb_dataservices_client._obs_getavailableboundaries(username, orgname, geom, timespan) AS query;
  
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot (username text, organization_name text, geom geometry(Geometry, 4326), time_span text DEFAULT NULL, geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getdemographicsnapshot (username, organization_name, geom, time_span, geometry_level);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot (username text, organization_name text, geom geometry(Geometry, 4326), geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getsegmentsnapshot (username, organization_name, geom, geometry_level);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundary (username text, organization_name text, geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundary (username, organization_name, geom, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundaryid (username text, organization_name text, geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundaryid (username, organization_name, geom, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundarybyid (username text, organization_name text, geometry_id text, boundary_id text, time_span text DEFAULT NULL)
RETURNS Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundarybyid (username, organization_name, geometry_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry (username text, organization_name text, geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getboundariesbygeometry (username, organization_name, geom, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius (username text, organization_name text, geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getboundariesbypointandradius (username, organization_name, geom, radius, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbygeometry (username text, organization_name text, geom geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getpointsbygeometry (username, organization_name, geom, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius (username text, organization_name text, geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getpointsbypointandradius (username, organization_name, geom, radius, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasure (username text, organization_name text, geom Geometry, measure_id text, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getmeasure (username, organization_name, geom, measure_id, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getcategory (username text, organization_name text, geom Geometry, category_id text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getcategory (username, organization_name, geom, category_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensusmeasure (username text, organization_name text, geom Geometry, name text, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getuscensusmeasure (username, organization_name, geom, name, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensuscategory (username text, organization_name text, geom Geometry, name text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getuscensuscategory (username, organization_name, geom, name, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpopulation (username text, organization_name text, geom Geometry, normalize text DEFAULT 'area', boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getpopulation (username, organization_name, geom, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_search (username text, organization_name text, search_term text, relevant_boundary text DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_search (username, organization_name, search_term, relevant_boundary);
  
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailableboundaries (username text, organization_name text, geom Geometry, time_span text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailableboundaries (username, organization_name, geom, time_span);
  
$$ LANGUAGE plproxy;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getdemographicsnapshot(geom geometry(Geometry, 4326), time_span text, geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getsegmentsnapshot(geom geometry(Geometry, 4326), geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundary(geom geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundaryid(geom geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundarybyid(geometry_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundariesbygeometry(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundariesbypointandradius(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpointsbygeometry(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpointsbypointandradius(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getmeasure(geom Geometry, measure_id text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getcategory(geom Geometry, category_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getuscensusmeasure(geom Geometry, name text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getuscensuscategory(geom Geometry, name text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpopulation(geom Geometry, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_search(search_term text, relevant_boundary text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailableboundaries(geom Geometry, time_span text) TO publicuser;

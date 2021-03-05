--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.30.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

CREATE TYPE cdb_dataservices_client.obs_meta_numerator AS (numer_id text, numer_name text, numer_description text, numer_weight text, numer_license text, numer_source text, numer_type text, numer_aggregate text, numer_extra jsonb, numer_tags jsonb, valid_denom boolean, valid_geom boolean, valid_timespan boolean);
CREATE TYPE cdb_dataservices_client.obs_meta_denominator AS (denom_id text, denom_name text, denom_description text, denom_weight text, denom_license text, denom_source text, denom_type text, denom_aggregate text, denom_extra jsonb, denom_tags jsonb, valid_numer boolean, valid_geom boolean, valid_timespan boolean);
CREATE TYPE cdb_dataservices_client.obs_meta_geometry AS (geom_id text, geom_name text, geom_description text, geom_weight text, geom_aggregate text, geom_license text, geom_source text, valid_numer boolean, valid_denom boolean, valid_timespan boolean, score numeric, numtiles bigint, notnull_percent numeric, numgeoms numeric, percentfill numeric, estnumgeoms numeric, meanmediansize numeric, geom_type text, geom_extra jsonb, geom_tags jsonb);
CREATE TYPE cdb_dataservices_client.obs_meta_timespan AS (timespan_id text, timespan_name text, timespan_description text, timespan_weight text, timespan_aggregate text, timespan_license text, timespan_source text, valid_numer boolean, valid_denom boolean, valid_geom boolean, timespan_type text, timespan_extra jsonb, timespan_tags jsonb);

DROP TYPE IF EXISTS cdb_dataservices_client.service_type; 
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing',
    'observatory'
);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_get_demographic_snapshot (geom public.geometry(Geometry, 4326) ,time_span text DEFAULT '2009 - 2013'::text ,geometry_level text DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_get_demographic_snapshot(username, orgname, geom, time_span, geometry_level) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_get_segment_snapshot (geom public.geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_get_segment_snapshot(username, orgname, geom, geometry_level) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdemographicsnapshot (geom public.geometry(Geometry, 4326) ,time_span text DEFAULT NULL ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdemographicsnapshot(username, orgname, geom, time_span, geometry_level);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getsegmentsnapshot (geom public.geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getsegmentsnapshot(username, orgname, geom, geometry_level);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundary (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getboundary(username, orgname, geom, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundaryid (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getboundaryid(username, orgname, geom, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundarybyid (geometry_id text ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getboundarybyid(username, orgname, geometry_id, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundariesbygeometry (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getboundariesbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getboundariesbypointandradius (geom public.geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getboundariesbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpointsbygeometry (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getpointsbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpointsbypointandradius (geom public.geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getpointsbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeasure (geom public.Geometry ,measure_id text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getmeasure(username, orgname, geom, measure_id, normalize, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeasurebyid (geom_ref text ,measure_id text ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getmeasurebyid(username, orgname, geom_ref, measure_id, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdata (geomvals geomval[] ,params json ,merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomvals, params, merge);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getdata (geomrefs text[] ,params json)
RETURNS TABLE(id text, data json) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomrefs, params);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getmeta (geom_ref public.Geometry(Geometry, 4326) ,params json ,max_timespan_rank integer DEFAULT NULL ,max_score_rank integer DEFAULT NULL ,target_geoms integer DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getmeta(username, orgname, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_metadatavalidation (geom_extent public.Geometry(Geometry, 4326) ,geom_type text ,params json ,target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_metadatavalidation(username, orgname, geom_extent, geom_type, params, target_geoms);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getcategory (geom public.Geometry ,category_id text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getcategory(username, orgname, geom, category_id, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getuscensusmeasure (geom public.Geometry ,name text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getuscensusmeasure(username, orgname, geom, name, normalize, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getuscensuscategory (geom public.Geometry ,name text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getuscensuscategory(username, orgname, geom, name, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getpopulation (geom public.Geometry ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_getpopulation(username, orgname, geom, normalize, boundary_id, time_span) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_search (search_term text ,relevant_boundary text DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_search(username, orgname, search_term, relevant_boundary);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailableboundaries (geom public.Geometry ,timespan text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailableboundaries(username, orgname, geom, timespan);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_dumpversion ()
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._obs_dumpversion(username, orgname) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailablenumerators (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailablenumerators(username, orgname, bounds, filter_tags, denom_id, geom_id, timespan);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getnumerators (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,section_tags text[] DEFAULT ARRAY[]::TEXT[] ,subsection_tags text[] DEFAULT ARRAY[]::TEXT[] ,other_tags text[] DEFAULT ARRAY[]::TEXT[] ,ids text[] DEFAULT ARRAY[]::TEXT[] ,name text DEFAULT NULL ,denom_id text DEFAULT '' ,geom_id text DEFAULT '' ,timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client.__obs_getnumerators(username, orgname, bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailabledenominators (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailabledenominators(username, orgname, bounds, filter_tags, numer_id, geom_id, timespan);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailablegeometries (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,timespan text DEFAULT NULL ,number_geometries integer DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailablegeometries(username, orgname, bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_getavailabletimespans (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailabletimespans(username, orgname, bounds, filter_tags, numer_id, denom_id, geom_id);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_legacybuildermetadata (aggregate_type text DEFAULT NULL)
RETURNS TABLE(name text, subsection json) AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_legacybuildermetadata(username, orgname, aggregate_type);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE TYPE cdb_dataservices_client.ds_fdw_metadata as (schemaname text, tabname text, servername text);
CREATE TYPE cdb_dataservices_client.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_PrepareTableOBS_GetMeasure(
    output_table_name text,
    params json
) RETURNS boolean AS $$
DECLARE
  username text;
  user_db_role text;
  orgname text;
  user_schema text;
  result boolean;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;

  SELECT session_user INTO user_db_role;

  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument';
  END IF;

  IF orgname IS NULL OR orgname = '' OR orgname = '""' THEN
    user_schema := 'public';
  ELSE
    user_schema := username;
  END IF;

  SELECT cdb_dataservices_client.__DST_PrepareTableOBS_GetMeasure(
      username,
      orgname,
      user_db_role,
      user_schema,
      output_table_name,
      params
  ) INTO result;

  RETURN result;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE
    SET search_path = pg_temp;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_PopulateTableOBS_GetMeasure(
    table_name text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
DECLARE
  username text;
  user_db_role text;
  orgname text;
  dbname text;
  user_schema text;
  result boolean;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;

  SELECT session_user INTO user_db_role;

  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument';
  END IF;

  IF orgname IS NULL OR orgname = '' OR orgname = '""' THEN
    user_schema := 'public';
  ELSE
    user_schema := username;
  END IF;

  SELECT current_database() INTO dbname;

  SELECT cdb_dataservices_client.__DST_PopulateTableOBS_GetMeasure(
      username,
      orgname,
      user_db_role,
      user_schema,
      dbname,
      table_name,
      output_table_name,
      params
  ) INTO result;

  RETURN result;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE
    SET search_path = pg_temp;



CREATE OR REPLACE FUNCTION cdb_dataservices_client.__DST_PrepareTableOBS_GetMeasure(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
    function_name = 'OBS_GetMeasure'
    # Obtain return types for augmentation procedure
    ds_return_metadata = plpy.execute("SELECT colnames, coltypes "
        "FROM cdb_dataservices_client._DST_GetReturnMetadata({username}::text, {orgname}::text, {function_name}::text, {params}::json);"
        .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params)
            )
        )
    if ds_return_metadata[0]["colnames"]:
        colnames_arr = ds_return_metadata[0]["colnames"]
        coltypes_arr = ds_return_metadata[0]["coltypes"]
    else:
        raise Exception('Error retrieving OBS_GetMeasure metadata')


    # Prepare column and type strings required in the SQL queries
    columns_with_types_arr = [colnames_arr[i] + ' ' + coltypes_arr[i] for i in range(0,len(colnames_arr))]
    columns_with_types = ','.join(columns_with_types_arr)

    # Create a new table with the required columns
    plpy.execute('CREATE TABLE "{schema}".{table_name} ( '
        'cartodb_id int, the_geom public.geometry, {columns_with_types} '
        ');'
        .format(schema=user_schema, table_name=output_table_name, columns_with_types=columns_with_types)
        )

    plpy.execute('ALTER TABLE "{schema}".{table_name} OWNER TO "{user}";'
        .format(schema=user_schema, table_name=output_table_name, user=user_db_role)
        )

    return True
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__DST_PopulateTableOBS_GetMeasure(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    dbname text,
    table_name text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
    function_name = 'OBS_GetMeasure'
    # Obtain return types for augmentation procedure
    ds_return_metadata = plpy.execute(
        "SELECT colnames, coltypes "
        "FROM cdb_dataservices_client._DST_GetReturnMetadata({username}::text, {orgname}::text, {function_name}::text, {params}::json);" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params)))

    if ds_return_metadata[0]["colnames"]:
        colnames_arr = ds_return_metadata[0]["colnames"]
        coltypes_arr = ds_return_metadata[0]["coltypes"]
    else:
        raise Exception('Error retrieving OBS_GetMeasure metadata')

    # Prepare column and type strings required in the SQL queries
    columns_with_types_arr = [
        colnames_arr[i] +
        ' ' +
        coltypes_arr[i] for i in range(
            0,
            len(colnames_arr))]
    columns_with_types = ','.join(columns_with_types_arr)
    aliased_colname_list = ','.join(
        ['result.' + name for name in colnames_arr])

    # Instruct the OBS server side to establish a FDW
    # The metadata is obtained as well in order to:
    #   - (a) be able to write the query to grab the actual data to be executed in the remote server via pl/proxy,
    #   - (b) be able to tell OBS to free resources when done.
    ds_fdw_metadata = plpy.execute(
        "SELECT schemaname, tabname, servername "
        "FROM cdb_dataservices_client._DST_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, "
        "{schema}::text, {dbname}::text, {table_name}::text);" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            user_db_role=plpy.quote_literal(user_db_role),
            schema=plpy.quote_literal(user_schema),
            dbname=plpy.quote_literal(dbname),
            table_name=plpy.quote_literal(table_name)))

    if ds_fdw_metadata[0]["schemaname"]:
        server_schema = ds_fdw_metadata[0]["schemaname"]
        server_table_name = ds_fdw_metadata[0]["tabname"]
        server_name = ds_fdw_metadata[0]["servername"]
    else:
        raise Exception('Error connecting dataset via FDW')

    # Create a new table with the required columns
    plpy.execute(
        'INSERT INTO "{schema}".{analysis_table_name} '
        'SELECT ut.cartodb_id, ut.the_geom, {colname_list} '
        'FROM "{schema}".{table_name} ut '
        'LEFT JOIN cdb_dataservices_client._DST_FetchJoinFdwTableData({username}::text, {orgname}::text, {server_schema}::text, {server_table_name}::text, '
        '{function_name}::text, {params}::json) '
        'AS result ({columns_with_types}, cartodb_id int)  '
        'ON result.cartodb_id = ut.cartodb_id;' .format(
            schema=user_schema,
            analysis_table_name=output_table_name,
            colname_list=aliased_colname_list,
            table_name=table_name,
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            server_schema=plpy.quote_literal(server_schema),
            server_table_name=plpy.quote_literal(server_table_name),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params),
            columns_with_types=columns_with_types))

    # Wipe user FDW data from the server
    wiped = plpy.execute(
        "SELECT cdb_dataservices_client._DST_DisconnectUserTable({username}::text, {orgname}::text, {server_schema}::text, "
        "{server_table_name}::text, {fdw_server}::text)" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            server_schema=plpy.quote_literal(server_schema),
            server_table_name=plpy.quote_literal(server_table_name),
            fdw_server=plpy.quote_literal(server_name)))

    return True
$$ LANGUAGE @@plpythonu@@ VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_ConnectUserTable(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    dbname text,
    table_name text
)RETURNS cdb_dataservices_client.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_ConnectUserTable;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_GetReturnMetadata(
    username text,
    orgname text,
    function_name text,
    params json
) RETURNS cdb_dataservices_client.ds_return_metadata AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_GetReturnMetadata;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_FetchJoinFdwTableData(
    username text,
    orgname text,
    table_schema text,
    table_name text,
    function_name text,
    params json
) RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_FetchJoinFdwTableData;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_DisconnectUserTable(
    username text,
    orgname text,
    table_schema text,
    table_name text,
    server_name text
) RETURNS boolean AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_DisconnectUserTable;
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_demographic_snapshot_exception_safe (geom public.geometry(Geometry, 4326) ,time_span text DEFAULT '2009 - 2013'::text ,geometry_level text DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_get_demographic_snapshot(username, orgname, geom, time_span, geometry_level) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_segment_snapshot_exception_safe (geom public.geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_get_segment_snapshot(username, orgname, geom, geometry_level) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot_exception_safe (geom public.geometry(Geometry, 4326) ,time_span text DEFAULT NULL ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdemographicsnapshot(username, orgname, geom, time_span, geometry_level);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot_exception_safe (geom public.geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getsegmentsnapshot(username, orgname, geom, geometry_level);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundary_exception_safe (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getboundary(username, orgname, geom, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundaryid_exception_safe (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getboundaryid(username, orgname, geom, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundarybyid_exception_safe (geometry_id text ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getboundarybyid(username, orgname, geometry_id, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry_exception_safe (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getboundariesbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius_exception_safe (geom public.geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getboundariesbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbygeometry_exception_safe (geom public.geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getpointsbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius_exception_safe (geom public.geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getpointsbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasure_exception_safe (geom public.Geometry ,measure_id text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getmeasure(username, orgname, geom, measure_id, normalize, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasurebyid_exception_safe (geom_ref text ,measure_id text ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getmeasurebyid(username, orgname, geom_ref, measure_id, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata_exception_safe (geomvals geomval[] ,params json ,merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomvals, params, merge);
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
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getdata(username, orgname, geomrefs, params);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeta_exception_safe (geom_ref public.Geometry(Geometry, 4326) ,params json ,max_timespan_rank integer DEFAULT NULL ,max_score_rank integer DEFAULT NULL ,target_geoms integer DEFAULT NULL)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getmeta(username, orgname, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_metadatavalidation_exception_safe (geom_extent public.Geometry(Geometry, 4326) ,geom_type text ,params json ,target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_metadatavalidation(username, orgname, geom_extent, geom_type, params, target_geoms);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getcategory_exception_safe (geom public.Geometry ,category_id text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getcategory(username, orgname, geom, category_id, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensusmeasure_exception_safe (geom public.Geometry ,name text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getuscensusmeasure(username, orgname, geom, name, normalize, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensuscategory_exception_safe (geom public.Geometry ,name text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getuscensuscategory(username, orgname, geom, name, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpopulation_exception_safe (geom public.Geometry ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_getpopulation(username, orgname, geom, normalize, boundary_id, time_span) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_search_exception_safe (search_term text ,relevant_boundary text DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_search(username, orgname, search_term, relevant_boundary);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailableboundaries_exception_safe (geom public.Geometry ,timespan text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailableboundaries(username, orgname, geom, timespan);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_dumpversion_exception_safe ()
RETURNS text AS $$
DECLARE
  ret text;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._obs_dumpversion(username, orgname) INTO ret; RETURN ret;
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
         RETURN ret;
  END;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablenumerators_exception_safe (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailablenumerators(username, orgname, bounds, filter_tags, denom_id, geom_id, timespan);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__obs_getnumerators_exception_safe (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,section_tags text[] DEFAULT ARRAY[]::TEXT[] ,subsection_tags text[] DEFAULT ARRAY[]::TEXT[] ,other_tags text[] DEFAULT ARRAY[]::TEXT[] ,ids text[] DEFAULT ARRAY[]::TEXT[] ,name text DEFAULT NULL ,denom_id text DEFAULT '' ,geom_id text DEFAULT '' ,timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabledenominators_exception_safe (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailabledenominators(username, orgname, bounds, filter_tags, numer_id, geom_id, timespan);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablegeometries_exception_safe (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,timespan text DEFAULT NULL ,number_geometries integer DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailablegeometries(username, orgname, bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabletimespans_exception_safe (bounds public.geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_getavailabletimespans(username, orgname, bounds, filter_tags, numer_id, denom_id, geom_id);
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_legacybuildermetadata_exception_safe (aggregate_type text DEFAULT NULL)
RETURNS TABLE(name text, subsection json) AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'observatory' THEN
    RAISE EXCEPTION 'Data Observatory permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_legacybuildermetadata(username, orgname, aggregate_type);
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
--
-- Exception-safe private DataServices API function
--

DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_demographic_snapshot (username text, orgname text, geom public.geometry(Geometry, 4326), time_span text, geometry_level text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_demographic_snapshot (username text, orgname text, geom public.geometry(Geometry, 4326), time_span text DEFAULT '2009 - 2013'::text, geometry_level text DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_get_demographic_snapshot (username, orgname, geom, time_span, geometry_level);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_get_segment_snapshot (username text, orgname text, geom public.geometry(Geometry, 4326), geometry_level text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_segment_snapshot (username text, orgname text, geom public.geometry(Geometry, 4326), geometry_level text DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_get_segment_snapshot (username, orgname, geom, geometry_level);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdemographicsnapshot (username text, orgname text, geom public.geometry(Geometry, 4326), time_span text, geometry_level text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot (username text, orgname text, geom public.geometry(Geometry, 4326), time_span text DEFAULT NULL, geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getdemographicsnapshot (username, orgname, geom, time_span, geometry_level);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getsegmentsnapshot (username text, orgname text, geom public.geometry(Geometry, 4326), geometry_level text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot (username text, orgname text, geom public.geometry(Geometry, 4326), geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getsegmentsnapshot (username, orgname, geom, geometry_level);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundary (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundary (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundary (username, orgname, geom, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundaryid (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundaryid (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundaryid (username, orgname, geom, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundarybyid (username text, orgname text, geometry_id text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundarybyid (username text, orgname text, geometry_id text, boundary_id text, time_span text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getboundarybyid (username, orgname, geometry_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbygeometry (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getboundariesbygeometry (username, orgname, geom, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getboundariesbypointandradius (username text, orgname text, geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius (username text, orgname text, geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getboundariesbypointandradius (username, orgname, geom, radius, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbygeometry (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbygeometry (username text, orgname text, geom public.geometry(Geometry, 4326), boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getpointsbygeometry (username, orgname, geom, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpointsbypointandradius (username text, orgname text, geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius (username text, orgname text, geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text DEFAULT NULL, overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getpointsbypointandradius (username, orgname, geom, radius, boundary_id, time_span, overlap_type);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeasure (username text, orgname text, geom public.Geometry, measure_id text, normalize text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasure (username text, orgname text, geom public.Geometry, measure_id text, normalize text DEFAULT NULL, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getmeasure (username, orgname, geom, measure_id, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeasurebyid (username text, orgname text, geom_ref text, measure_id text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasurebyid (username text, orgname text, geom_ref text, measure_id text, boundary_id text, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getmeasurebyid (username, orgname, geom_ref, measure_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata (username text, orgname text, geomvals geomval[], params json, merge boolean);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata (username text, orgname text, geomvals geomval[], params json, merge boolean DEFAULT true)
RETURNS TABLE(id int, data json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getdata (username, orgname, geomvals, params, merge);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getdata (username text, orgname text, geomrefs text[], params json);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdata (username text, orgname text, geomrefs text[], params json)
RETURNS TABLE(id text, data json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getdata (username, orgname, geomrefs, params);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getmeta (username text, orgname text, geom_ref public.Geometry(Geometry, 4326), params json, max_timespan_rank integer, max_score_rank integer, target_geoms integer);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeta (username text, orgname text, geom_ref public.Geometry(Geometry, 4326), params json, max_timespan_rank integer DEFAULT NULL, max_score_rank integer DEFAULT NULL, target_geoms integer DEFAULT NULL)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getmeta (username, orgname, geom_ref, params, max_timespan_rank, max_score_rank, target_geoms);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_metadatavalidation (username text, orgname text, geom_extent public.Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_metadatavalidation (username text, orgname text, geom_extent public.Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_metadatavalidation (username, orgname, geom_extent, geom_type, params, target_geoms);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getcategory (username text, orgname text, geom public.Geometry, category_id text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getcategory (username text, orgname text, geom public.Geometry, category_id text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getcategory (username, orgname, geom, category_id, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensusmeasure (username text, orgname text, geom public.Geometry, name text, normalize text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensusmeasure (username text, orgname text, geom public.Geometry, name text, normalize text DEFAULT NULL, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getuscensusmeasure (username, orgname, geom, name, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getuscensuscategory (username text, orgname text, geom public.Geometry, name text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensuscategory (username text, orgname text, geom public.Geometry, name text, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getuscensuscategory (username, orgname, geom, name, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getpopulation (username text, orgname text, geom public.Geometry, normalize text, boundary_id text, time_span text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpopulation (username text, orgname text, geom public.Geometry, normalize text DEFAULT NULL, boundary_id text DEFAULT NULL, time_span text DEFAULT NULL)
RETURNS numeric AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_getpopulation (username, orgname, geom, normalize, boundary_id, time_span);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_search (username text, orgname text, search_term text, relevant_boundary text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_search (username text, orgname text, search_term text, relevant_boundary text DEFAULT NULL)
RETURNS TABLE(id text, description text, name text, aggregate text, source text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_search (username, orgname, search_term, relevant_boundary);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailableboundaries (username text, orgname text, geom public.Geometry, timespan text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailableboundaries (username text, orgname text, geom public.Geometry, timespan text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailableboundaries (username, orgname, geom, timespan);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_dumpversion (username text, orgname text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_dumpversion (username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.obs_dumpversion (username, orgname);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablenumerators (username text, orgname text, bounds public.geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablenumerators (username text, orgname text, bounds public.geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailablenumerators (username, orgname, bounds, filter_tags, denom_id, geom_id, timespan);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client.__obs_getnumerators (username text, orgname text, bounds public.geometry(Geometry, 4326), section_tags text[], subsection_tags text[], other_tags text[], ids text[], name text, denom_id text, geom_id text, timespan text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client.__obs_getnumerators (username text, orgname text, bounds public.geometry(Geometry, 4326) DEFAULT NULL, section_tags text[] DEFAULT ARRAY[]::TEXT[], subsection_tags text[] DEFAULT ARRAY[]::TEXT[], other_tags text[] DEFAULT ARRAY[]::TEXT[], ids text[] DEFAULT ARRAY[]::TEXT[], name text DEFAULT NULL, denom_id text DEFAULT '', geom_id text DEFAULT '', timespan text DEFAULT '')
RETURNS SETOF cdb_dataservices_client.obs_meta_numerator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server._obs_getnumerators (username, orgname, bounds, section_tags, subsection_tags, other_tags, ids, name, denom_id, geom_id, timespan);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabledenominators (username text, orgname text, bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabledenominators (username text, orgname text, bounds public.geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, geom_id text DEFAULT NULL, timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailabledenominators (username, orgname, bounds, filter_tags, numer_id, geom_id, timespan);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailablegeometries (username text, orgname text, bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text, number_geometries integer);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablegeometries (username text, orgname text, bounds public.geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, timespan text DEFAULT NULL, number_geometries integer DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailablegeometries (username, orgname, bounds, filter_tags, numer_id, denom_id, timespan, number_geometries);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_getavailabletimespans (username text, orgname text, bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabletimespans (username text, orgname text, bounds public.geometry(Geometry, 4326) DEFAULT NULL, filter_tags text[] DEFAULT NULL, numer_id text DEFAULT NULL, denom_id text DEFAULT NULL, geom_id text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_getavailabletimespans (username, orgname, bounds, filter_tags, numer_id, denom_id, geom_id);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._obs_legacybuildermetadata (username text, orgname text, aggregate_type text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_legacybuildermetadata (username text, orgname text, aggregate_type text DEFAULT NULL)
RETURNS TABLE(name text, subsection json) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.obs_legacybuildermetadata (username, orgname, aggregate_type);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_PreCheck(
    source_query text,
    parameters json
) RETURNS boolean AS $$
DECLARE
    errors text[];
    validator_errors text[];
    validator_error text;
    valid boolean;
    geoms record;
BEGIN
    errors := (ARRAY[])::TEXT[];
    FOR geoms IN EXECUTE format('SELECT ST_GeometryType(the_geom) as geom_type,
                                 bool_and(st_isvalid(the_geom)) as valid,
                                 avg(st_npoints(the_geom)) as avg_vertex,
                                 ST_SetSRID(ST_Extent(the_geom), 4326) as extent,
                                 count(*)::INT as numgeoms
                                 FROM (%s) as _source
                                 GROUP BY ST_GeometryType(the_geom)', source_query)
    LOOP
        IF geoms.geom_type NOT IN ('ST_Polygon', 'ST_MultiPolygon', 'ST_Point') THEN
            errors := array_append(errors, format($data$'Geometry type %s not supported'$data$, geoms.geom_type));
        END IF;

        IF geoms.valid IS FALSE THEN
            errors := array_append(errors, 'There are invalid geometries in the input data, please try to fix them');
        END IF;

        -- 1000 vertex for a geometry is a limit we have in the obs_getdata function. You can check here
        -- https://github.com/CartoDB/observatory-extension/blob/1.6.0/src/pg/sql/41_observatory_augmentation.sql#L813
        IF geoms.avg_vertex > 1000 THEN
            errors := array_append(errors, 'The average number of vertices per geometry is greater than 1000, please try to simplify them');
        END IF;

        -- OBS specific part
        EXECUTE 'SELECT valid, errors
        FROM cdb_dataservices_client.OBS_MetadataValidation($1, $2, $3, $4)'
        INTO valid, validator_errors
        USING geoms.extent, geoms.geom_type, parameters, geoms.numgeoms;
        IF valid is FALSE THEN
            FOR validator_error IN EXECUTE 'SELECT unnest($1)' USING validator_errors
            LOOP
                errors := array_append(errors, validator_error);
            END LOOP;
        END IF;
    END LOOP;

    IF CARDINALITY(errors) > 0 THEN
        RAISE EXCEPTION '%', errors;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql' VOLATILE PARALLEL UNSAFE;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_get_demographic_snapshot(geom public.geometry(Geometry, 4326), time_span text, geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_get_demographic_snapshot_exception_safe(geom public.geometry(Geometry, 4326), time_span text, geometry_level text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_get_segment_snapshot(geom public.geometry(Geometry, 4326), geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_get_segment_snapshot_exception_safe(geom public.geometry(Geometry, 4326), geometry_level text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getdemographicsnapshot(geom public.geometry(Geometry, 4326), time_span text, geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot_exception_safe(geom public.geometry(Geometry, 4326), time_span text, geometry_level text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getsegmentsnapshot(geom public.geometry(Geometry, 4326), geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot_exception_safe(geom public.geometry(Geometry, 4326), geometry_level text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundary(geom public.geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundary_exception_safe(geom public.geometry(Geometry, 4326), boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundaryid(geom public.geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundaryid_exception_safe(geom public.geometry(Geometry, 4326), boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundarybyid(geometry_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundarybyid_exception_safe(geometry_id text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundariesbygeometry(geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry_exception_safe(geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getboundariesbypointandradius(geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius_exception_safe(geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpointsbygeometry(geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpointsbygeometry_exception_safe(geom public.geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpointsbypointandradius(geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius_exception_safe(geom public.geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getmeasure(geom public.Geometry, measure_id text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getmeasure_exception_safe(geom public.Geometry, measure_id text, normalize text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getmeasurebyid(geom_ref text, measure_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getmeasurebyid_exception_safe(geom_ref text, measure_id text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getdata(geomvals geomval[], params json, merge boolean) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getdata_exception_safe(geomvals geomval[], params json, merge boolean )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getdata(geomrefs text[], params json) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getdata_exception_safe(geomrefs text[], params json )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getmeta(geom_ref public.Geometry(Geometry, 4326), params json, max_timespan_rank integer, max_score_rank integer, target_geoms integer) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getmeta_exception_safe(geom_ref public.Geometry(Geometry, 4326), params json, max_timespan_rank integer, max_score_rank integer, target_geoms integer )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_metadatavalidation(geom_extent public.Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_metadatavalidation_exception_safe(geom_extent public.Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getcategory(geom public.Geometry, category_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getcategory_exception_safe(geom public.Geometry, category_id text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getuscensusmeasure(geom public.Geometry, name text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getuscensusmeasure_exception_safe(geom public.Geometry, name text, normalize text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getuscensuscategory(geom public.Geometry, name text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getuscensuscategory_exception_safe(geom public.Geometry, name text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getpopulation(geom public.Geometry, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpopulation_exception_safe(geom public.Geometry, normalize text, boundary_id text, time_span text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_search(search_term text, relevant_boundary text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_search_exception_safe(search_term text, relevant_boundary text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailableboundaries(geom public.Geometry, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailableboundaries_exception_safe(geom public.Geometry, timespan text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_dumpversion() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_dumpversion_exception_safe( )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailablenumerators(bounds public.geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailablenumerators_exception_safe(bounds public.geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getnumerators(bounds public.geometry(Geometry, 4326), section_tags text[], subsection_tags text[], other_tags text[], ids text[], name text, denom_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.__obs_getnumerators_exception_safe(bounds public.geometry(Geometry, 4326), section_tags text[], subsection_tags text[], other_tags text[], ids text[], name text, denom_id text, geom_id text, timespan text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailabledenominators(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailabledenominators_exception_safe(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailablegeometries(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text, number_geometries integer) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailablegeometries_exception_safe(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text, number_geometries integer )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_getavailabletimespans(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailabletimespans_exception_safe(bounds public.geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_legacybuildermetadata(aggregate_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_legacybuildermetadata_exception_safe(aggregate_type text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._DST_PrepareTableOBS_GetMeasure(output_table_name text, params json) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._DST_PopulateTableOBS_GetMeasure(table_name text, output_table_name text, params json) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._OBS_PreCheck(source_query text, params JSON) TO publicuser;

--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cdb_dataservices_client" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;
-- Taken from https://wiki.postgresql.org/wiki/Count_estimate
CREATE FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) RETURNS INTEGER AS
$func$
DECLARE
    rec   record;
    ROWS  INTEGER;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN ROWS IS NOT NULL;
    END LOOP;

    RETURN ROWS;
END
$func$ LANGUAGE plpgsql;

-- Taken from https://stackoverflow.com/a/48013356/351721
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb) RETURNS text[] AS $f$
    SELECT array_agg(x) || ARRAY[]::text[] FROM jsonb_array_elements_text($1) t(x);
$f$ LANGUAGE sql IMMUTABLE;
--
-- Geocoder server connection config
--
-- The purpose of this function is provide to the PL/Proxy functions
-- the connection string needed to connect with the server

CREATE OR REPLACE FUNCTION cdb_dataservices_client._server_conn_str()
RETURNS text AS $$
DECLARE
  db_connection_str text;
BEGIN
  SELECT cartodb.cdb_conf_getconf('geocoder_server_config')->'connection_str' INTO db_connection_str;
  SELECT trim(both '"' FROM db_connection_str) INTO db_connection_str;
  RETURN db_connection_str;
END;
$$ LANGUAGE 'plpgsql' STABLE PARALLEL SAFE;
CREATE TYPE cdb_dataservices_client._entity_config AS (
    username text,
    organization_name text,
    apikey_permissions json
);

--
-- Get entity config function
--
-- The purpose of this function is to retrieve the username and organization name from
-- a) schema where he/her is the owner in case is an organization user
-- b) entity_name from the cdb_conf database in case is a non organization user
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_entity_config()
RETURNS record AS $$
DECLARE
    result cdb_dataservices_client._entity_config;
    apikey_config json;
    is_organization boolean;
    organization_name text DEFAULT NULL;
BEGIN
    SELECT cartodb.cdb_conf_getconf('api_keys_'||session_user) INTO apikey_config;

    SELECT cartodb.cdb_conf_getconf('user_config')->'is_organization' INTO is_organization;
    IF is_organization IS NULL THEN
        RAISE EXCEPTION 'User must have user configuration in the config table';
    ELSIF is_organization = TRUE THEN
        SELECT cartodb.cdb_conf_getconf('user_config')->>'entity_name' INTO organization_name;
    END IF;
    result.username = apikey_config->>'username';
    result.organization_name = organization_name;
    result.apikey_permissions = apikey_config->'permissions';
    RETURN result;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL SAFE
    SET search_path = pg_temp;

CREATE TYPE cdb_dataservices_client.isoline AS (
    center geometry(Geometry,4326),
    data_range integer,
    the_geom geometry(Multipolygon,4326)
);

CREATE TYPE cdb_dataservices_client.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Point,4326),
    metadata jsonb
);

CREATE TYPE cdb_dataservices_client.simple_route AS (
    shape geometry(LineString,4326),
    length real,
    duration integer
);

-- For quotas and services configuration
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing'
);

CREATE TYPE cdb_dataservices_client.service_quota_info AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT
);

CREATE TYPE cdb_dataservices_client.service_quota_info_batch AS (
    service cdb_dataservices_client.service_type,
    monthly_quota NUMERIC,
    used_quota NUMERIC,
    soft_limit BOOLEAN,
    provider TEXT,
    max_batch_size NUMERIC
);
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_admin0_polygon (country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_admin0_polygon(username, orgname, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_admin1_polygon (admin1_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_admin1_polygon (admin1_name text ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point (city_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point (city_name text ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point (city_name text ,admin1_name text ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, admin1_name, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_polygon (postal_code text ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_postalcode_polygon(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_polygon (postal_code double precision ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_postalcode_polygon(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_point (postal_code text ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_postalcode_point(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_point (postal_code double precision ,country_name text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_postalcode_point(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_ipaddress_point (ip_address text)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_ipaddress_point(username, orgname, ip_address) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point (searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client.__cdb_bulk_geocode_street_point(username, orgname, searches);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_here_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_here_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_google_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_google_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapbox_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_mapbox_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_tomtom_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_geocodio_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_geocodio_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapzen_geocode_street_point (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
RETURNS public.Geometry AS $$
DECLARE
  ret public.Geometry;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_mapzen_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_isodistance (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_isodistance(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_isochrone (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_isochrone(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapbox_isochrone (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_isochrone(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_isochrone (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isochrone(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapzen_isochrone (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapzen_isochrone(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapbox_isodistance (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_isodistance(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_tomtom_isodistance (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isodistance(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_mapzen_isodistance (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapzen_isodistance(username, orgname, source, mode, range, options);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_route_point_to_point (origin public.geometry(Point, 4326) ,destination public.geometry(Point, 4326) ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'routing' THEN
    RAISE EXCEPTION 'Routing permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT * FROM cdb_dataservices_client._cdb_route_point_to_point(username, orgname, origin, destination, mode, options, units) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_route_with_waypoints (waypoints public.geometry(Point, 4326)[] ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'routing' THEN
    RAISE EXCEPTION 'Routing permission denied' USING ERRCODE = '01007';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT * FROM cdb_dataservices_client._cdb_route_with_waypoints(username, orgname, waypoints, mode, options, units) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_quota_info ()
RETURNS SETOF service_quota_info AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info(username, orgname);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch ()
RETURNS SETOF service_quota_info_batch AS $$
DECLARE
  
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info_batch(username, orgname);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN AS $$
DECLARE
  ret BOOLEAN;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_enough_quota(username, orgname, service, input_size) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Public dataservices API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_service_get_rate_limit (service text)
RETURNS json AS $$
DECLARE
  ret json;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT cdb_dataservices_client._cdb_service_get_rate_limit(username, orgname, service) INTO ret; RETURN ret;
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_user_rate_limit(username, orgname, service, rate_limit);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_org_rate_limit(username, orgname, service, rate_limit);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  PERFORM cdb_dataservices_client._cdb_service_set_server_rate_limit(username, orgname, service, rate_limit);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point (query text,
    street_column text, city_column text default null, state_column text default null, country_column text default null, batch_size integer DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE
  query_row_count integer;
  enough_quota boolean;
  remaining_quota integer;
  max_batch_size integer;

  cartodb_id_batch integer;
  batches_n integer;
  DEFAULT_BATCH_SIZE CONSTANT numeric := 100;
  MAX_SAFE_BATCH_SIZE CONSTANT numeric := 5000;

  temp_table_name text;
  username text;
  orgname text;
  apikey_permissions json;
BEGIN
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied' USING ERRCODE = '01007';
  END IF;

  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  SELECT csqi.monthly_quota - csqi.used_quota AS remaining_quota, csqi.max_batch_size
  INTO remaining_quota, max_batch_size
  FROM cdb_dataservices_client.cdb_service_quota_info_batch() csqi
  WHERE service = 'hires_geocoder';
  RAISE DEBUG 'remaining_quota: %; max_batch_size: %', remaining_quota, max_batch_size;

  IF batch_size IS NULL THEN
    batch_size := max_batch_size;
  ELSIF batch_size > max_batch_size THEN
    RAISE EXCEPTION 'batch_size must be lower than %', max_batch_size + 1;
  END IF;

  IF batch_size > MAX_SAFE_BATCH_SIZE THEN
    batch_size := MAX_SAFE_BATCH_SIZE;
  END IF;

  EXECUTE format('SELECT count(1), ceil(count(1)::float/%s) FROM (%s) _x', batch_size, query)
  INTO query_row_count, batches_n;

  RAISE DEBUG 'cdb_bulk_geocode_street_point --> query_row_count: %; query: %; country: %; state: %; city: %; street: %',
      query_row_count, query, country_column, state_column, city_column, street_column;
  SELECT cdb_dataservices_client.cdb_enough_quota('hires_geocoder', query_row_count) INTO enough_quota;
  IF enough_quota IS NULL OR NOT enough_quota THEN
    RAISE EXCEPTION 'Remaining quota: %. Estimated cost: %', remaining_quota, query_row_count;
  END IF;

  RAISE DEBUG 'batches_n: %', batches_n;

  temp_table_name := 'bulk_geocode_street_' || md5(random()::text);

  EXECUTE format('CREATE TEMPORARY TABLE %s ' ||
   '(cartodb_id integer, the_geom public.geometry(Point,4326), metadata jsonb)',
   temp_table_name);

  select
    coalesce(street_column, ''''''), coalesce(city_column, ''''''),
    coalesce(state_column, ''''''), coalesce(country_column, '''''')
  into street_column, city_column, state_column, country_column;

  IF batches_n > 0 THEN
    FOR cartodb_id_batch in 0..(batches_n - 1)
    LOOP
      EXECUTE format(
        'WITH geocoding_data as (' ||
        '   SELECT ' ||
        '      json_build_object(''id'', cartodb_id, ''address'', %s, ''city'', %s, ''state'', %s, ''country'', %s) as data , ' ||
        '      floor((row_number() over () - 1)::float/$1) as batch' ||
        '   FROM (%s) _x' ||
        ') ' ||
        'INSERT INTO %s SELECT (cdb_dataservices_client._cdb_bulk_geocode_street_point(jsonb_agg(data))).* ' ||
        'FROM geocoding_data ' ||
        'WHERE batch = $2', street_column, city_column, state_column, country_column, query, temp_table_name)
      USING batch_size, cartodb_id_batch;

    END LOOP;
  END IF;

  RETURN QUERY EXECUTE 'SELECT * FROM ' || quote_ident(temp_table_name);
END;
$$  LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin0_polygon_exception_safe (country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_admin0_polygon(username, orgname, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe (admin1_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe (admin1_name text ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text ,admin1_name text ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, admin1_name, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe (postal_code text ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_postalcode_polygon(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe (postal_code double precision ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_postalcode_polygon(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe (postal_code text ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_postalcode_point(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe (postal_code double precision ,country_name text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_postalcode_point(username, orgname, postal_code, country_name) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_ipaddress_point_exception_safe (ip_address text)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_ipaddress_point(username, orgname, ip_address) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point_exception_safe (searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client.__cdb_bulk_geocode_street_point(username, orgname, searches);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_here_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_google_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_mapbox_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocodio_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_geocodio_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'geocoding' THEN
    RAISE EXCEPTION 'Geocoding permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_mapzen_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isodistance_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isochrone_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_isochrone_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isochrone_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapzen_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_isodistance_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapbox_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_tomtom_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isodistance_exception_safe (source public.geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_mapzen_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_point_to_point_exception_safe (origin public.geometry(Point, 4326) ,destination public.geometry(Point, 4326) ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'routing' THEN
    RAISE EXCEPTION 'Routing permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT * FROM cdb_dataservices_client._cdb_route_point_to_point(username, orgname, origin, destination, mode, options, units) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_with_waypoints_exception_safe (waypoints public.geometry(Point, 4326)[] ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  IF apikey_permissions IS NULL OR NOT apikey_permissions::jsonb ? 'routing' THEN
    RAISE EXCEPTION 'Routing permission denied';
  END IF;
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT * FROM cdb_dataservices_client._cdb_route_with_waypoints(username, orgname, waypoints, mode, options, units) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info_exception_safe ()
RETURNS SETOF service_quota_info AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info(username, orgname);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info_batch_exception_safe ()
RETURNS SETOF service_quota_info_batch AS $$
DECLARE
  
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info_batch(username, orgname);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_enough_quota_exception_safe (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN AS $$
DECLARE
  ret BOOLEAN;
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
  apikey_permissions json;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;


  BEGIN
    SELECT cdb_dataservices_client._cdb_enough_quota(username, orgname, service, input_size) INTO ret; RETURN ret;
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit_exception_safe (service text)
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
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o, p INTO username, orgname, apikey_permissions FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
  
  
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
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
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text, p json);
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
$$  LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE
    SET search_path = pg_temp;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin0_polygon (username text, orgname text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin0_polygon (username text, orgname text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_admin0_polygon (username, orgname, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin1_polygon (username text, orgname text, admin1_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon (username text, orgname text, admin1_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_admin1_polygon (username, orgname, admin1_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_admin1_polygon (username text, orgname text, admin1_name text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon (username text, orgname text, admin1_name text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_admin1_polygon (username, orgname, admin1_name, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_namedplace_point (username, orgname, city_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_namedplace_point (username, orgname, city_name, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text, admin1_name text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point (username text, orgname text, city_name text, admin1_name text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_namedplace_point (username, orgname, city_name, admin1_name, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_polygon (username text, orgname text, postal_code text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon (username text, orgname text, postal_code text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon (username, orgname, postal_code, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_polygon (username text, orgname text, postal_code double precision, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon (username text, orgname text, postal_code double precision, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_polygon (username, orgname, postal_code, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_point (username text, orgname text, postal_code text, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point (username text, orgname text, postal_code text, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point (username, orgname, postal_code, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_postalcode_point (username text, orgname text, postal_code double precision, country_name text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point (username text, orgname text, postal_code double precision, country_name text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_postalcode_point (username, orgname, postal_code, country_name);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_ipaddress_point (username text, orgname text, ip_address text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_ipaddress_point (username text, orgname text, ip_address text)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_ipaddress_point (username, orgname, ip_address);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client.__cdb_bulk_geocode_street_point (username text, orgname text, searches jsonb);
CREATE OR REPLACE FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point (username text, orgname text, searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server._cdb_bulk_geocode_street_point (username, orgname, searches);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_here_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_here_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_google_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_google_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_mapbox_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_tomtom_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_geocodio_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocodio_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_geocodio_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_geocode_street_point (username text, orgname text, searchtext text, city text, state_province text, country text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point (username text, orgname text, searchtext text, city text DEFAULT NULL, state_province text DEFAULT NULL, country text DEFAULT NULL)
RETURNS public.Geometry AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_mapzen_geocode_street_point (username, orgname, searchtext, city, state_province, country);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapbox_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_tomtom_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isochrone (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapzen_isochrone (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapbox_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapbox_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapbox_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_tomtom_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_tomtom_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_mapzen_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[]);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isodistance (username text, orgname text, source public.geometry(Geometry, 4326), mode text, range integer[], options text[] DEFAULT ARRAY[]::text[])
RETURNS SETOF cdb_dataservices_client.isoline AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_mapzen_isodistance (username, orgname, source, mode, range, options);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_point_to_point (username text, orgname text, origin public.geometry(Point, 4326), destination public.geometry(Point, 4326), mode text, options text[], units text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_point_to_point (username text, orgname text, origin public.geometry(Point, 4326), destination public.geometry(Point, 4326), mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_route_point_to_point (username, orgname, origin, destination, mode, options, units);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_route_with_waypoints (username text, orgname text, waypoints public.geometry(Point, 4326)[], mode text, options text[], units text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_with_waypoints (username text, orgname text, waypoints public.geometry(Point, 4326)[], mode text, options text[] DEFAULT ARRAY[]::text[], units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_route_with_waypoints (username, orgname, waypoints, mode, options, units);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info (username text, orgname text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info (username text, orgname text)
RETURNS SETOF service_quota_info AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_service_quota_info (username, orgname);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info_batch (username text, orgname text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info_batch (username text, orgname text)
RETURNS SETOF service_quota_info_batch AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_service_quota_info_batch (username, orgname);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_enough_quota (username text, orgname text, service TEXT, input_size NUMERIC);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_enough_quota (username text, orgname text, service TEXT, input_size NUMERIC)
RETURNS BOOLEAN AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_enough_quota (username, orgname, service, input_size);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_get_rate_limit (username text, orgname text, service text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit (username text, orgname text, service text)
RETURNS json AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_service_get_rate_limit (username, orgname, service);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_user_rate_limit (username text, orgname text, service text, rate_limit json);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_user_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_service_set_user_rate_limit (username, orgname, service, rate_limit);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_org_rate_limit (username text, orgname text, service text, rate_limit json);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_org_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_service_set_org_rate_limit (username, orgname, service, rate_limit);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_set_server_rate_limit (username text, orgname text, service text, rate_limit json);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_set_server_rate_limit (username text, orgname text, service text, rate_limit json)
RETURNS void AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT cdb_dataservices_server.cdb_service_set_server_rate_limit (username, orgname, service, rate_limit);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;
-- Make sure by default there are no permissions for publicuser
-- NOTE: this happens at extension creation time, as part of an implicit transaction.
REVOKE ALL PRIVILEGES ON SCHEMA cdb_dataservices_client FROM PUBLIC, publicuser CASCADE;

-- Grant permissions on the schema to publicuser (but just the schema)
GRANT USAGE ON SCHEMA cdb_dataservices_client TO publicuser;

-- Revoke execute permissions on all functions in the schema by default
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_dataservices_client FROM PUBLIC, publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_admin0_polygon(country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin0_polygon_exception_safe(country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_admin1_polygon(admin1_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_admin1_polygon(admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point(city_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point(city_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_namedplace_point(city_name text, admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, admin1_name text, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_polygon(postal_code text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe(postal_code text, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_polygon(postal_code double precision, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe(postal_code double precision, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_point(postal_code text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe(postal_code text, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_postalcode_point(postal_code double precision, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe(postal_code double precision, country_name text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_ipaddress_point(ip_address text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_ipaddress_point_exception_safe(ip_address text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point(searches jsonb) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point_exception_safe(searches jsonb )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_here_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_google_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapbox_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapbox_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_geocodio_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocodio_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapzen_geocode_street_point(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_isodistance(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_isodistance_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_isochrone(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_isochrone_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapbox_isochrone(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapbox_isochrone_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_isochrone(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_isochrone_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapzen_isochrone(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_isochrone_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapbox_isodistance(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapbox_isodistance_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_tomtom_isodistance(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_tomtom_isodistance_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_mapzen_isodistance(source public.geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_isodistance_exception_safe(source public.geometry(Geometry, 4326), mode text, range integer[], options text[] )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_route_point_to_point(origin public.geometry(Point, 4326), destination public.geometry(Point, 4326), mode text, options text[], units text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_route_point_to_point_exception_safe(origin public.geometry(Point, 4326), destination public.geometry(Point, 4326), mode text, options text[], units text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_route_with_waypoints(waypoints public.geometry(Point, 4326)[], mode text, options text[], units text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_route_with_waypoints_exception_safe(waypoints public.geometry(Point, 4326)[], mode text, options text[], units text )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_quota_info() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_quota_info_exception_safe( )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_quota_info_batch_exception_safe( )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_enough_quota(service TEXT, input_size NUMERIC) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_enough_quota_exception_safe(service TEXT, input_size NUMERIC )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_get_rate_limit(service text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_get_rate_limit_exception_safe(service text )  TO publicuser;



GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point(query text, street_column text, city_column text, state_column text, country_column text, batch_size integer) TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb) TO publicuser;

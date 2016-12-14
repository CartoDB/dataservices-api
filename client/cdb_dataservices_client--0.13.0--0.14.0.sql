--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.14.0'" to load this file. \quit

--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin0_polygon_exception_safe (country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_admin0_polygon(username, orgname, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe (admin1_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe (admin1_name text ,country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_admin1_polygon(username, orgname, admin1_name, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text ,country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe (city_name text ,admin1_name text ,country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_namedplace_point(username, orgname, city_name, admin1_name, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe (postal_code text ,country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_postalcode_polygon(username, orgname, postal_code, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe (postal_code text ,country_name text)
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
      SELECT cdb_dataservices_client._cdb_geocode_postalcode_point(username, orgname, postal_code, country_name) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_ipaddress_point_exception_safe (ip_address text)
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
      SELECT cdb_dataservices_client._cdb_geocode_ipaddress_point(username, orgname, ip_address) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._cdb_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._cdb_here_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._cdb_google_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point_exception_safe (searchtext text ,city text DEFAULT NULL ,state_province text DEFAULT NULL ,country text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._cdb_mapzen_geocode_street_point(username, orgname, searchtext, city, state_province, country) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isodistance_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._cdb_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_isochrone_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._cdb_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isochrone_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._cdb_mapzen_isochrone(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_mapzen_isodistance_exception_safe (source geometry(Geometry, 4326) ,mode text ,range integer[] ,options text[] DEFAULT ARRAY[]::text[])
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
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._cdb_mapzen_isodistance(username, orgname, source, mode, range, options);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_point_to_point_exception_safe (origin geometry(Point, 4326) ,destination geometry(Point, 4326) ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
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
      SELECT * FROM cdb_dataservices_client._cdb_route_point_to_point(username, orgname, origin, destination, mode, options, units) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_route_with_waypoints_exception_safe (waypoints geometry(Point, 4326)[] ,mode text ,options text[] DEFAULT ARRAY[]::text[] ,units text DEFAULT 'kilometers')
RETURNS cdb_dataservices_client.simple_route AS $$
DECLARE
  ret cdb_dataservices_client.simple_route;
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
      SELECT * FROM cdb_dataservices_client._cdb_route_with_waypoints(username, orgname, waypoints, mode, options, units) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_demographic_snapshot_exception_safe (geom geometry(Geometry, 4326) ,time_span text DEFAULT '2009 - 2013'::text ,geometry_level text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._obs_get_demographic_snapshot(username, orgname, geom, time_span, geometry_level) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_get_segment_snapshot_exception_safe (geom geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._obs_get_segment_snapshot(username, orgname, geom, geometry_level) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot_exception_safe (geom geometry(Geometry, 4326) ,time_span text DEFAULT NULL ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getdemographicsnapshot(username, orgname, geom, time_span, geometry_level);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot_exception_safe (geom geometry(Geometry, 4326) ,geometry_level text DEFAULT NULL)
RETURNS SETOF JSON AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getsegmentsnapshot(username, orgname, geom, geometry_level);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundary_exception_safe (geom geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._obs_getboundary(username, orgname, geom, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundaryid_exception_safe (geom geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
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
      SELECT cdb_dataservices_client._obs_getboundaryid(username, orgname, geom, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundarybyid_exception_safe (geometry_id text ,boundary_id text ,time_span text DEFAULT NULL)
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
      SELECT cdb_dataservices_client._obs_getboundarybyid(username, orgname, geometry_id, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry_exception_safe (geom geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getboundariesbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius_exception_safe (geom geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getboundariesbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbygeometry_exception_safe (geom geometry(Geometry, 4326) ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getpointsbygeometry(username, orgname, geom, boundary_id, time_span, overlap_type);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius_exception_safe (geom geometry(Geometry, 4326) ,radius numeric ,boundary_id text ,time_span text DEFAULT NULL ,overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getpointsbypointandradius(username, orgname, geom, radius, boundary_id, time_span, overlap_type);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getmeasure_exception_safe (geom Geometry ,measure_id text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
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
      SELECT cdb_dataservices_client._obs_getmeasure(username, orgname, geom, measure_id, normalize, boundary_id, time_span) INTO ret;
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
      SELECT cdb_dataservices_client._obs_getmeasurebyid(username, orgname, geom_ref, measure_id, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getcategory_exception_safe (geom Geometry ,category_id text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
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
      SELECT cdb_dataservices_client._obs_getcategory(username, orgname, geom, category_id, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensusmeasure_exception_safe (geom Geometry ,name text ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
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
      SELECT cdb_dataservices_client._obs_getuscensusmeasure(username, orgname, geom, name, normalize, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getuscensuscategory_exception_safe (geom Geometry ,name text ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS text AS $$
DECLARE
  ret text;
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
      SELECT cdb_dataservices_client._obs_getuscensuscategory(username, orgname, geom, name, boundary_id, time_span) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getpopulation_exception_safe (geom Geometry ,normalize text DEFAULT NULL ,boundary_id text DEFAULT NULL ,time_span text DEFAULT NULL)
RETURNS numeric AS $$
DECLARE
  ret numeric;
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
      SELECT cdb_dataservices_client._obs_getpopulation(username, orgname, geom, normalize, boundary_id, time_span) INTO ret;
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
      SELECT * FROM cdb_dataservices_client._obs_search(username, orgname, search_term, relevant_boundary);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailableboundaries_exception_safe (geom Geometry ,timespan text DEFAULT NULL)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getavailableboundaries(username, orgname, geom, timespan);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_dumpversion_exception_safe ()
RETURNS text AS $$
DECLARE
  ret text;
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
      SELECT cdb_dataservices_client._obs_dumpversion(username, orgname) INTO ret;
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
--
-- Exception-safe private DataServices API function
--

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablenumerators_exception_safe (bounds geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
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
      RETURN QUERY
      SELECT * FROM cdb_dataservices_client._obs_getavailablenumerators(username, orgname, bounds, filter_tags, denom_id, geom_id, timespan);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabledenominators_exception_safe (bounds geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,geom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_denominator AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getavailabledenominators(username, orgname, bounds, filter_tags, numer_id, geom_id, timespan);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailablegeometries_exception_safe (bounds geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,timespan text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_geometry AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getavailablegeometries(username, orgname, bounds, filter_tags, numer_id, denom_id, timespan);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_getavailabletimespans_exception_safe (bounds geometry(Geometry, 4326) DEFAULT NULL ,filter_tags text[] DEFAULT NULL ,numer_id text DEFAULT NULL ,denom_id text DEFAULT NULL ,geom_id text DEFAULT NULL)
RETURNS SETOF cdb_dataservices_client.obs_meta_timespan AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_getavailabletimespans(username, orgname, bounds, filter_tags, numer_id, denom_id, geom_id);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_legacybuildermetadata_exception_safe (aggregate_type text DEFAULT NULL)
RETURNS TABLE(name text, subsection json) AS $$
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
      SELECT * FROM cdb_dataservices_client._obs_legacybuildermetadata(username, orgname, aggregate_type);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info_exception_safe ()
RETURNS SETOF service_quota_info AS $$
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
      SELECT * FROM cdb_dataservices_client._cdb_service_quota_info(username, orgname);
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_enough_quota_exception_safe (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN AS $$
DECLARE
  ret BOOLEAN;
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
      SELECT cdb_dataservices_client._cdb_enough_quota(username, orgname, service, input_size) INTO ret;
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


GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin0_polygon_exception_safe(country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_admin1_polygon_exception_safe(admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_namedplace_point_exception_safe(city_name text, admin1_name text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_polygon_exception_safe(postal_code text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_postalcode_point_exception_safe(postal_code text, country_name text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_ipaddress_point_exception_safe(ip_address text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_here_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_google_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_geocode_street_point_exception_safe(searchtext text, city text, state_province text, country text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_isochrone_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_mapzen_isodistance_exception_safe(source geometry(Geometry, 4326), mode text, range integer[], options text[]) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_route_point_to_point_exception_safe(origin geometry(Point, 4326), destination geometry(Point, 4326), mode text, options text[], units text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_route_with_waypoints_exception_safe(waypoints geometry(Point, 4326)[], mode text, options text[], units text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_get_demographic_snapshot_exception_safe(geom geometry(Geometry, 4326), time_span text, geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_get_segment_snapshot_exception_safe(geom geometry(Geometry, 4326), geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getdemographicsnapshot_exception_safe(geom geometry(Geometry, 4326), time_span text, geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getsegmentsnapshot_exception_safe(geom geometry(Geometry, 4326), geometry_level text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundary_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundaryid_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundarybyid_exception_safe(geometry_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundariesbygeometry_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getboundariesbypointandradius_exception_safe(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpointsbygeometry_exception_safe(geom geometry(Geometry, 4326), boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpointsbypointandradius_exception_safe(geom geometry(Geometry, 4326), radius numeric, boundary_id text, time_span text, overlap_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getmeasure_exception_safe(geom Geometry, measure_id text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getmeasurebyid_exception_safe(geom_ref text, measure_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getcategory_exception_safe(geom Geometry, category_id text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getuscensusmeasure_exception_safe(geom Geometry, name text, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getuscensuscategory_exception_safe(geom Geometry, name text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getpopulation_exception_safe(geom Geometry, normalize text, boundary_id text, time_span text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_search_exception_safe(search_term text, relevant_boundary text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailableboundaries_exception_safe(geom Geometry, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_dumpversion_exception_safe() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailablenumerators_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], denom_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailabledenominators_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, geom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailablegeometries_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, timespan text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_getavailabletimespans_exception_safe(bounds geometry(Geometry, 4326), filter_tags text[], numer_id text, denom_id text, geom_id text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_legacybuildermetadata_exception_safe(aggregate_type text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_quota_info_exception_safe() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_enough_quota_exception_safe(service TEXT, input_size NUMERIC) TO publicuser;

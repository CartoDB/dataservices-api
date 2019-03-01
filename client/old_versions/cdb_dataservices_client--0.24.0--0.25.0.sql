--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '<%= version %>'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
-- Taken from https://wiki.postgresql.org/wiki/Count_estimate
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) RETURNS INTEGER AS
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
$f$ LANGUAGE sql IMMUTABLE;--

CREATE TYPE cdb_dataservices_client.geocoding AS (
    cartodb_id integer,
    the_geom geometry(Multipolygon,4326),
    metadata jsonb
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

CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point (searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
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

  RETURN QUERY SELECT * FROM cdb_dataservices_client.__cdb_bulk_geocode_street_point(username, orgname, searches);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

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
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info_batch(username, orgname);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

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
BEGIN
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
  IF remaining_quota < query_row_count THEN
    RAISE EXCEPTION 'Remaining quota: %. Estimated cost: %', remaining_quota, query_row_count;
  END IF;

  RAISE DEBUG 'batches_n: %', batches_n;

  temp_table_name := 'bulk_geocode_street_' || md5(random()::text);

  EXECUTE format('CREATE TEMPORARY TABLE %s ' ||
   '(cartodb_id integer, the_geom geometry(Multipolygon,4326), metadata jsonb)',
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
$$ LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE;

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
    RETURN QUERY SELECT * FROM cdb_dataservices_client.__cdb_bulk_geocode_street_point(username, orgname, searches);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;
        
  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

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
    RETURN QUERY SELECT * FROM cdb_dataservices_client._cdb_service_quota_info_batch(username, orgname);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;

  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE;

DROP FUNCTION IF EXISTS cdb_dataservices_client.__cdb_bulk_geocode_street_point (username text, orgname text, searches jsonb);
CREATE OR REPLACE FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point (username text, orgname text, searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server._cdb_bulk_geocode_street_point (username, orgname, searches);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info_batch (username text, orgname text);
CREATE OR REPLACE FUNCTION cdb_dataservices_client._cdb_service_quota_info_batch (username text, orgname text)
RETURNS SETOF service_quota_info_batch AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  
  SELECT * FROM cdb_dataservices_server.cdb_service_quota_info_batch (username, orgname);
  
$$ LANGUAGE plproxy VOLATILE PARALLEL UNSAFE;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point(searches jsonb) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point_exception_safe(searches jsonb )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch() TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._cdb_service_quota_info_batch_exception_safe( )  TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point(query text, street_column text, city_column text, state_column text, country_column text, batch_size integer) TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.__cdb_bulk_geocode_street_point (username text, orgname text, searches jsonb) TO publicuser;

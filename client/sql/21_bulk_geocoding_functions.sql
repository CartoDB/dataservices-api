CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point (query text,
    street_column text, city_column text default null, state_column text default null, country_column text default null, batch_size integer DEFAULT 100)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE
  query_row_count integer;
  enough_quota boolean;
  remaining_quota integer;

  cartodb_id_batch integer;
  batches_n integer;
  DEFAULT_BATCH_SIZE CONSTANT numeric := 100;
  MAX_BATCH_SIZE CONSTANT numeric := 10000;
  current_row_count integer ;

  temp_table_name text;
BEGIN
  IF batch_size IS NULL THEN
    RAISE EXCEPTION 'batch_size can''t be null';
  ELSIF batch_size > MAX_BATCH_SIZE THEN
    RAISE EXCEPTION 'batch_size must be lower than %', MAX_BATCH_SIZE + 1;
  END IF;

  EXECUTE format('SELECT COUNT(1) from (%s) _x', query) INTO query_row_count;

  RAISE DEBUG 'cdb_bulk_geocode_street_point --> query_row_count: %; query: %; country: %; state: %; city: %; street: %',
      query_row_count, query, country_column, state_column, city_column, street_column;
  SELECT cdb_dataservices_client.cdb_enough_quota('hires_geocoder', query_row_count) INTO enough_quota;
  IF enough_quota IS NOT NULL AND NOT enough_quota THEN
    SELECT csqi.monthly_quota - csqi.used_quota AS remaining_quota
    INTO remaining_quota
    FROM cdb_dataservices_client.cdb_service_quota_info() csqi
    WHERE service = 'hires_geocoder';
    RAISE EXCEPTION 'Remaining quota: %. Estimated cost: %', remaining_quota, query_row_count;
  END IF;

  EXECUTE format('SELECT ceil(max(cartodb_id)::float/%s) FROM (%s) _x', batch_size, query) INTO batches_n;

  RAISE DEBUG 'batches_n: %', batches_n;

  temp_table_name := 'bulk_geocode_street_' || md5(random()::text);

  EXECUTE format('CREATE TEMPORARY TABLE %s ' ||
   '(cartodb_id integer, the_geom geometry(Multipolygon,4326), metadata jsonb)',
   temp_table_name);

  select
    coalesce(street_column, ''''''), coalesce(city_column, ''''''),
    coalesce(state_column, ''''''), coalesce(country_column, '''''')
  into street_column, city_column, state_column, country_column;

  FOR cartodb_id_batch in 0..(batches_n - 1)
  LOOP

    EXECUTE format(
      'WITH geocoding_data as (' ||
      '   SELECT ' ||
      '      json_build_object(''id'', cartodb_id, ''address'', %s, ''city'', %s, ''state'', %s, ''country'', %s) as data , ' ||
      '      floor((cartodb_id-1)::float/$1) as batch' ||
      '   FROM (%s) _x' ||
      ') ' ||
      'INSERT INTO %s SELECT (cdb_dataservices_client._cdb_bulk_geocode_street_point(jsonb_agg(data))).* ' ||
      'FROM geocoding_data ' ||
      'WHERE batch = $2', street_column, city_column, state_column, country_column, query, temp_table_name)
    USING batch_size, cartodb_id_batch;

    GET DIAGNOSTICS current_row_count = ROW_COUNT;
    RAISE DEBUG 'Batch % --> %', cartodb_id_batch, current_row_count;

  END LOOP;

  RETURN QUERY EXECUTE 'SELECT * FROM ' || quote_ident(temp_table_name);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point (query text, searchtext text)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
DECLARE
  monthly_quota integer;
  used_quota integer;
  soft_limit boolean;
  provider text;

  remaining_quota integer;
  estimated_row_count integer;

  cartodb_id_batch integer;
  batches_n integer;
  BATCHES_SIZE CONSTANT numeric := 100;
  current_row_count integer ;
BEGIN
  SELECT csqi.monthly_quota, csqi.used_quota, csqi.soft_limit, csqi.provider
  into monthly_quota, used_quota, soft_limit, provider
  FROM cdb_dataservices_client.cdb_service_quota_info() csqi WHERE service = 'hires_geocoder';

  remaining_quota := monthly_quota - used_quota;
  estimated_row_count := count_estimate(query);
  RAISE DEBUG 'cdb_bulk_geocode_street_point --> estimated: %, remaining: %, monthly_quota: %, used_quota: %, soft_limit: %, provider: %',
      estimated_row_count, remaining_quota, monthly_quota, used_quota, soft_limit, provider;
  IF estimated_row_count > remaining_quota THEN
    RAISE EXCEPTION 'Remaining quota: %. Estimated cost: %', remaining_quota, estimated_row_count;
  END IF;

  EXECUTE format('SELECT ceil(max(cartodb_id)::float/%s) FROM (%s) _x', BATCHES_SIZE, query) INTO batches_n;

  RAISE DEBUG 'batches_n: %', batches_n;

  CREATE TEMPORARY TABLE bulk_geocode_street_point
      (cartodb_id integer, the_geom geometry(Multipolygon,4326), metadata jsonb);

  FOR cartodb_id_batch in 0..(batches_n - 1)
  LOOP

    EXECUTE format(
      'WITH geocoding_data as (' ||
      '   SELECT json_build_object(''id'', cartodb_id, ''address'', %s) as data , floor((cartodb_id-1)::float/$1) as batch' ||
      '   FROM (%s) _x' ||
      ')' ||
      'INSERT INTO bulk_geocode_street_point SELECT (cdb_dataservices_client._cdb_bulk_geocode_street_point(jsonb_agg(data))).* ' ||
      'FROM geocoding_data ' ||
      'WHERE batch = $2', searchtext, query)
    USING BATCHES_SIZE, cartodb_id_batch;

    GET DIAGNOSTICS current_row_count = ROW_COUNT;
    RAISE DEBUG 'Batch % --> %', cartodb_id_batch, current_row_count;

  END LOOP;

  RETURN QUERY SELECT * FROM bulk_geocode_street_point;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER VOLATILE PARALLEL UNSAFE;

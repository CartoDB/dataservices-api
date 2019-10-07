\set VERBOSITY terse

ALTER FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch() RENAME TO cdb_service_quota_info_batch_mocked;
CREATE FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch ()
RETURNS SETOF cdb_dataservices_client.service_quota_info_batch AS $$
  SELECT 'hires_geocoder'::cdb_dataservices_client.service_type AS service, 0::NUMERIC AS monthly_quota, 0::NUMERIC AS used_quota, FALSE AS soft_limit, 'google' AS provider, 1::NUMERIC AS max_batch_size;
$$ LANGUAGE SQL;

ALTER FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC) RENAME TO cdb_enough_quota_mocked;
CREATE FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN as $$
  SELECT FALSE;
$$ LANGUAGE SQL;

ALTER FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point(searches jsonb) RENAME TO _cdb_bulk_geocode_street_point_mocked;
CREATE FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point(searches jsonb)
RETURNS SETOF cdb_dataservices_client.geocoding AS $$
BEGIN
  RAISE NOTICE 'called with this searches: %', searches;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER STABLE PARALLEL UNSAFE SET search_path = pg_temp;

-- No permissions granted
-- Test bulk size not mandatory (it will get the optimal)
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''', null, null, null, null);
-- Test quota check by mocking quota 0
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''');

-- Grant other permissions but geocoding
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"username": "test_user", "permissions": ["routing", "isolines"]}');
-- Test bulk size not mandatory (it will get the optimal)
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''', null, null, null, null);
-- Test quota check by mocking quota 0
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''');

-- Grant geocoding permissions
SELECT CDB_Conf_SetConf('api_keys_postgres', '{"username": "test_user", "permissions": ["geocoding"]}');
-- Test bulk size not mandatory (it will get the optimal)
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''', null, null, null, null);
-- Test quota check by mocking quota 0
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''');

-- Check that when cdb_enough_quota returns true (ie. when soft_limit is set to true, even if not enough quota)
-- it is able to proceed with the bulk geocode
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN as $$
  SELECT TRUE;
$$ LANGUAGE SQL;
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''');

-- Remove permissions
SELECT CDB_Conf_RemoveConf('api_keys_postgres');

DROP FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch;
DROP FUNCTION cdb_dataservices_client.cdb_enough_quota;
DROP FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point;

ALTER FUNCTION cdb_dataservices_client.cdb_enough_quota_mocked (service TEXT ,input_size NUMERIC) RENAME TO cdb_enough_quota;
ALTER FUNCTION cdb_dataservices_client.cdb_service_quota_info_batch_mocked() RENAME TO cdb_service_quota_info_batch;
ALTER FUNCTION cdb_dataservices_client._cdb_bulk_geocode_street_point_mocked(searches jsonb) RENAME TO _cdb_bulk_geocode_street_point;

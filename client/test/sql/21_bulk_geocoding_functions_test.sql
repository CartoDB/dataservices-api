\set VERBOSITY terse

ALTER FUNCTION cdb_dataservices_client.cdb_service_quota_info() RENAME TO cdb_service_quota_info_mocked;
CREATE FUNCTION cdb_dataservices_client.cdb_service_quota_info ()
RETURNS SETOF cdb_dataservices_client.service_quota_info AS $$
  SELECT 'hires_geocoder'::cdb_dataservices_client.service_type AS service, 0::NUMERIC AS monthly_quota, 0::NUMERIC AS used_quota, FALSE AS soft_limit, 'google' AS provider, 1::NUMERIC AS max_batch_size;
$$ LANGUAGE SQL;

ALTER FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC) RENAME TO cdb_enough_quota_mocked;
CREATE FUNCTION cdb_dataservices_client.cdb_enough_quota (service TEXT ,input_size NUMERIC)
RETURNS BOOLEAN as $$
  SELECT FALSE;
$$ LANGUAGE SQL;

-- Test bulk size not mandatory (it will get the optimal)
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''', null, null, null, null);

-- Test quota check by mocking quota 0
SELECT cdb_dataservices_client.cdb_bulk_geocode_street_point('select 1 as cartodb_id', '''Valladolid, Spain''');

DROP FUNCTION cdb_dataservices_client.cdb_service_quota_info;
DROP FUNCTION cdb_dataservices_client.cdb_enough_quota;

ALTER FUNCTION cdb_dataservices_client.cdb_enough_quota_mocked (service TEXT ,input_size NUMERIC) RENAME TO cdb_enough_quota;
ALTER FUNCTION cdb_dataservices_client.cdb_service_quota_info_mocked() RENAME TO cdb_service_quota_info;


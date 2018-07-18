--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '<%= version %>'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_count_estimate(query text);

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_bulk_geocode_street_point (jsonb);

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_service_quota_info_batch();

DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_bulk_geocode_street_point (text, text, text, text, text, integer);

DROP FUNCTION IF EXISTS cdb_dataservices_client.__cdb_bulk_geocode_street_point_exception_safe (jsonb);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info_batch_exception_safe ();

DROP FUNCTION IF EXISTS cdb_dataservices_client.__cdb_bulk_geocode_street_point (text, text, jsonb);

DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_service_quota_info_batch (text, text);

DROP TYPE IF EXISTS cdb_dataservices_client.service_quota_info_batch;

DROP TYPE IF EXISTS cdb_dataservices_client.geocoding;

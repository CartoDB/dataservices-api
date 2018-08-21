--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '<%= version %>'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade


DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_quota_info_batch(TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_google_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_heremaps_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_tomtom_geocode_street_point(TEXT, TEXT, jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_server._cdb_bulk_mapbox_geocode_street_point(TEXT, TEXT, jsonb);
DROP TYPE IF EXISTS cdb_dataservices_server.geocoding;
DROP TYPE IF EXISTS cdb_dataservices_server.service_quota_info_batch;

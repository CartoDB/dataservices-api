--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.24.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_client.cdb_bulk_geocode_street_point (searchtext jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_bulk_geocode_street_point (username text, orgname text, searchtext jsonb);
DROP FUNCTION IF EXISTS cdb_dataservices_client._cdb_bulk_geocode_street_point_exception_safe (searchtext jsonb);
DROP TYPE IF EXISTS cdb_dataservices_client.geocoding;

--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.30.1'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade

-- DROP FUNCTION IF EXISTS TODO

DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_numerator;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_denominator;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_geometry;
DROP TYPE IF EXISTS cdb_dataservices_client.obs_meta_timespan;
DROP TYPE IF EXISTS cdb_dataservices_client.ds_fdw_metadata;
DROP TYPE IF EXISTS cdb_dataservices_client.ds_return_metadata;

DROP TYPE IF EXISTS cdb_dataservices_client.service_type; 
CREATE TYPE cdb_dataservices_client.service_type AS ENUM (
    'isolines',
    'hires_geocoder',
    'routing'
);

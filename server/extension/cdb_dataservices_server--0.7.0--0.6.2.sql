--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.6.2'" to load this file. \quit
DROP FUNCTION IF EXISTS cdb_dataservices_server._get_data_observatory_config(text, text);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_do_get_demographic_snapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_do_get_segment_snapshot(TEXT, TEXT, geometry(Geometry, 4326), TEXT);
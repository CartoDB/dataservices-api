--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.24.2'" to load this file. \quit

DROP IF EXISTS FUNCTION cdb_dataservices_server._OBS_GetNumerators (text, text, geometry(Geometry, 4326), text[], text[] , text[], text[] , text, text, text,text);

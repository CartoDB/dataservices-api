--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION cdb_dataservices_client" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

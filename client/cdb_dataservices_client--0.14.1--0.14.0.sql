--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.14.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",public,cdb_dataservices_client;

-- This release introduces no changes other than the use of
-- search path in the install and migration scripts

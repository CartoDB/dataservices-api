--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.18.1'" to load this file. \quit

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_enough_quota(
  username TEXT,
  orgname TEXT,
  service_ TEXT,
  input_size NUMERIC);

DROP FUNCTION IF EXISTS cdb_dataservices_server.cdb_service_quota_info(
  username TEXT,
  orgname TEXT);

DROP TYPE IF EXISTS cdb_dataservices_server.service_quota_info;

DROP TYPE IF EXISTS cdb_dataservices_server.service_type;

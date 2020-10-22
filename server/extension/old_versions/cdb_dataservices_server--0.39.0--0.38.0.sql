--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.38.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade

-- Create geomval if it doesn't exist (in postgis 3+ it only exists in postgis_raster)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'geomval') THEN
        CREATE TYPE cdb_dataservices_server.geomval AS (
            geom geometry,
            val double precision
        );
    END IF;
END$$;

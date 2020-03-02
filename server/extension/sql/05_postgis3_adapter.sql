-- PG12_DEPRECATED
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
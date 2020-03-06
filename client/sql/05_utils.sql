-- Taken from https://wiki.postgresql.org/wiki/Count_estimate
CREATE FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) RETURNS INTEGER AS
$func$
DECLARE
    rec   record;
    ROWS  INTEGER;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN ROWS IS NOT NULL;
    END LOOP;

    RETURN ROWS;
END
$func$ LANGUAGE plpgsql;

-- Taken from https://stackoverflow.com/a/48013356/351721
CREATE OR REPLACE FUNCTION cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb) RETURNS text[] AS $f$
    SELECT array_agg(x) || ARRAY[]::text[] FROM jsonb_array_elements_text($1) t(x);
$f$ LANGUAGE sql IMMUTABLE;


-- PG12_DEPRECATED
-- Create geomval if it doesn't exist (in postgis 3+ it only exists in postgis_raster)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'geomval') THEN
        CREATE TYPE cdb_dataservices_client.geomval AS (
            geom geometry,
            val double precision
        );
    END IF;
END$$;
-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon('test_user', 'test_orgname', 'California');
SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon('test_user', 'test_orgname', 'California', 'United States');

-- Insert dummy data into country decoder table
INSERT INTO country_decoder (synonyms, iso3) VALUES (Array['united states'], 'USA');

-- Insert some dummy data and geometry to return
INSERT INTO global_province_polygons (synonyms, iso3, the_geom) VALUES (Array['california'], 'USA', ST_GeomFromText(
  'POLYGON((-71.1031880899493 42.3152774590236,
            -71.1031627617667 42.3152960829043,
            -71.102923838298 42.3149156848307,
            -71.1031880899493 42.3152774590236))',4326)
);

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon('test_user', 'test_orgname', 'California');
SELECT cdb_geocoder_server.cdb_geocode_admin1_polygon('test_user', 'test_orgname', 'California', 'United States');

-- Check for admin1 signatures
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = 'cdb_geocode_admin1_polygon'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = 'cdb_geocode_admin1_polygon'
              AND oidvectortypes(p.proargtypes)  = 'text, text, text, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = '_cdb_geocode_admin1_polygon'
              AND oidvectortypes(p.proargtypes)  = 'text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = '_cdb_geocode_admin1_polygon'
              AND oidvectortypes(p.proargtypes)  = 'text, text');
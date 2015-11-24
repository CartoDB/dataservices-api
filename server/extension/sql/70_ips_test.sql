-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_ipaddress_point(session_user, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', '0.0.0.0');

-- Insert dummy data into ip_address_locations
INSERT INTO ip_address_locations VALUES ('::ffff:0.0.0.0'::inet, (ST_SetSRID(ST_MakePoint('40.40', '3.71'), 4326)));

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.geocode_ipaddress_point(session_user, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', '0.0.0.0');

-- Check for namedplaces signatures (point and polygon)
SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = 'geocode_ipaddress_point'
              AND oidvectortypes(p.proargtypes)  = 'name, json, json, text');

SELECT exists(SELECT *
              FROM pg_proc p
              INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
              WHERE ns.nspname = 'cdb_geocoder_server'
              AND proname = '_geocode_ipaddress_point'
              AND oidvectortypes(p.proargtypes)  = 'text');
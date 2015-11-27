-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_geocoder_client;

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.cdb_geocode_ipaddress_point(user_id name, user_config JSON, geocoder_config JSON, ip_address text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.cdb_geocode_ipaddress_point invoked with params (%, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', ip_address;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocode_ipaddress_point('8.8.8.8');

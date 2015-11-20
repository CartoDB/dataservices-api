-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin1_polygon(user_id name, user_config JSON, geocoder_config JSON, admin1_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_admin1_polygon invoked with params (%, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', admin1_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin1_polygon(user_id name, user_config JSON, geocoder_config JSON, admin1_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_admin1_polygon invoked with params (%, %, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', admin1_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_admin1_polygon('California');
SELECT cdb_geocoder_client.geocode_admin1_polygon('California', 'United States');

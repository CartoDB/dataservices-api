-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_namedplace_point(user_id name, user_config JSON, geocoder_config JSON, city_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_namedplace_point invoked with params (%, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', city_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_namedplace_point(user_id name, user_config JSON, geocoder_config JSON, city_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_namedplace_point invoked with params (%, %, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', city_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_namedplace_point(user_id name, user_config JSON, geocoder_config JSON, city_name text, admin1_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_namedplace_point invoked with params (%, %, %, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', city_name, admin1_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx');
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx', 'Spain');
SELECT cdb_geocoder_client.geocode_namedplace_point('Elx', 'Valencia', 'Spain');


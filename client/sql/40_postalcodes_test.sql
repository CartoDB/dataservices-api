-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_postalcode_polygon(user_id name, user_config JSON, geocoder_config JSON, postal_code text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_postalcode_polygon invoked with params (%, %, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', postal_code, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_postalcode_point(user_id name, user_config JSON, geocoder_config JSON, postal_code text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_postalcode_point invoked with params (%, %, %, %, %)', user_id, '{"is_organization": false, "entity_name": "test_user"}', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}', postal_code, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocoder_client.geocode_postalcode_point('03204', 'Spain');

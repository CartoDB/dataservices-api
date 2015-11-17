-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin1_polygon(user_id name, tx_id bigint, admin1_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_admin1_polygon invoked with params (%, %, %)', user_id, 'some_transaction_id', admin1_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_admin1_polygon(user_id name, tx_id bigint, admin1_name text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_admin1_polygon invoked with params (%, %, %, %)', user_id, 'some_transaction_id', admin1_name, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_admin1_polygon('California');
SELECT cdb_geocoder_client.geocode_admin1_polygon('California', 'United States');

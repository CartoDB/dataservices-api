-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_postalcode_polygon(user_id name, tx_id bigint, postal_code text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_postalcode_polygon invoked with params (%, %, %, %)', user_id, 'some_transaction_id', postal_code, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_postalcode_point(user_id name, tx_id bigint, postal_code text, country_name text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_postalcode_point invoked with params (%, %, %, %)', user_id, 'some_transaction_id', postal_code, country_name;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_postalcode_polygon('03204', 'Spain');
SELECT cdb_geocoder_client.geocode_postalcode_point('03204', 'Spain');

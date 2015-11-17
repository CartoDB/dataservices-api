-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_geocoder_server.geocode_ipaddress_point(user_id name, tx_id bigint, ip_address text)
RETURNS Geometry AS $$
BEGIN
  RAISE NOTICE 'cdb_geocoder_server.geocode_ipaddress_point invoked with params (%, %, %)', user_id, 'some_transaction_id', ip_address;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT cdb_geocoder_client.geocode_ipaddress_point('8.8.8.8');

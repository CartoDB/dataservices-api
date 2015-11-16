--
-- Public geocoder API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

---- geocode_ip(city_name text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client.geocode_ip(ip_address text)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
BEGIN
  SELECT cdb_geocoder_client._geocode_ip(session_user, txid_current(), ip_address) INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- TODO: review all permissions stuff [I'd explicitly grant permissions to the public functions]

--------------------------------------------------------------------------------

---- geocode_ip(ip_address text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client._geocode_ip(user_id name, tx_id bigint, ip_address text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.geocode_ip(user_id, tx_id, ip_address);
$$ LANGUAGE plproxy;

--
-- Public geocoder API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

---- geocode_postalcode_polygon(postal_code text, country_name text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client.geocode_postalcode_polygon(postal_code text, country_name text)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
BEGIN
  SELECT cdb_geocoder_client._geocode_postalcode_polygon(session_user, txid_current(), postal_code, country_name) INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

---- geocode_postalcode_polygon(postal_code integer, country_name text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client.geocode_postalcode_point(postal_code text, country_name text)
RETURNS Geometry AS $$
DECLARE
  ret Geometry;
BEGIN
  SELECT cdb_geocoder_client._geocode_postalcode_point(session_user, txid_current(), postal_code, country_name) INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

-- TODO: review all permissions stuff [I'd explicitly grant permissions to the public functions]

--------------------------------------------------------------------------------

---- geocode_postalcode_polygon(postal_code text, country_name text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client._geocode_postalcode_polygon(user_id name, tx_id bigint, postal_code text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.geocode_postalcode_polygon(user_id, tx_id, postal_code, country_name);
$$ LANGUAGE plproxy;

---- geocode_postalcode_polygon(postal_code text, country_name text)
CREATE OR REPLACE FUNCTION cdb_geocoder_client._geocode_postalcode_point(user_id name, tx_id bigint, postal_code text, country_name text)
RETURNS Geometry AS $$
  CONNECT cdb_geocoder_client._server_conn_str();
  SELECT cdb_geocoder_server.geocode_postalcode_polygon(user_id, tx_id, postal_code, country_name);
$$ LANGUAGE plproxy;

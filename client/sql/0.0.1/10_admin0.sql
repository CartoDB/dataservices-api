--
-- Public geocoder API function
--
-- These are the only ones with permissions to publicuser role
-- and should also be the only ones with SECURITY DEFINER

CREATE OR REPLACE FUNCTION geocode_admin0_polygons(country_name text)
RETURNS Geometry AS $$
DECLARE
  db_connection_str text;
  ret Geometry;
BEGIN
  SELECT _config_get('db_connection_str') INTO db_connection_str;
  SELECT _geocode_admin0_polygons(session_user, txid_current(), db_connection_str, country_name) INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


-- TODO: review all permissions stuff [I'd explicitly grant permissions to the public functions]

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _geocode_admin0_polygons(user_id name, tx_id bigint, db_connection_str text, country_name text)
RETURNS Geometry AS $$
  -- TODO check if we can move the config to its own function
  CONNECT db_connection_str;
  SELECT geocode_admin0(user_id, tx_id, country_name);
$$ LANGUAGE plproxy;

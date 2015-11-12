-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_ip_point(session_user, txid_current(), '0.0.0.0');

-- Insert dummy data into ip_address_locations
INSERT INTO ip_address_locations VALUES ('::ffff:0.0.0.0'::inet, (ST_SetSRID(ST_MakePoint('40.40', '3.71'), 4326)));

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.geocode_ip_point(session_user, txid_current(), '0.0.0.0');

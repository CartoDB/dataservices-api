-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_postalcode_point(session_user, txid_current(), '03204');

-- Insert dummy data into ip_address_locations
INSERT INTO global_postal_code_points (the_geom, iso3, postal_code, postal_code_num) VALUES (
  '0101000020E61000000000000000E040408036B47414764840',
  'ESP',
  '03204',
  3204
);

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.geocode_postalcode_point(session_user, txid_current(), '03204');

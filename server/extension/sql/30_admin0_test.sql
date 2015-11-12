-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_admin0_polygon(session_user, txid_current(), 'Spain');

-- Insert some dummy synonym
INSERT INTO admin0_synonyms (name, adm0_a3) VALUES ('Spain', 'ESP');

-- Insert some dummy geometry to return
INSERT INTO ne_admin0_v3 (adm0_a3, the_geom) VALUES('ESP', ST_GeomFromText(
  'POLYGON((-71.1031880899493 42.3152774590236,
            -71.1031627617667 42.3152960829043,
            -71.102923838298 42.3149156848307,
            -71.1031880899493 42.3152774590236))',4326)
);

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.geocode_admin0_polygon(session_user, txid_current(), 'Spain');

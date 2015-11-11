-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_admin1_polygons(session_user, txid_current(), 'California');

-- Insert some dummy data and geometry to return
INSERT INTO global_province_polygons (synonyms, the_geom) VALUES (Array['Califonia'], ST_GeomFromText(
  'POLYGON((-71.1031880899493 42.3152774590236,
            -71.1031627617667 42.3152960829043,
            -71.102923838298 42.3149156848307,
            -71.1031880899493 42.3152774590236))',4326)
);

-- This should return the polygon inserted above
SELECT cdb_geocoder_server.geocode_admin1_polygons(session_user, txid_current(), 'California');

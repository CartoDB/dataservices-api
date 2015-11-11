-- Check that the public function is callable, even with no data
-- It should return NULL
SELECT cdb_geocoder_server.geocode_namedplace(session_user, txid_current(), 'Elx');

-- Insert dummy data into points table
INSERT INTO global_cities_points_limited (geoname_id, name, iso2, admin1, admin2, population, lowername, the_geom) VALUES (3128760, 'Elche', 'ES', 'VA', 'AL', 34534, 'elche', ST_GeomFromText(
  'POINT(0.6983 39.26787)',4326)
);

-- Insert dummy data into alternates table
INSERT INTO global_cities_alternates_limited (geoname_id, name, preferred, lowername, admin1_geonameid, iso2, admin1, the_geom) VALUES (3128760, 'Elx', true, 'elx', '000000', 'ES', 'VA', ST_GeomFromText(
  'POINT(0.6983 39.26787)',4326)
);

-- Insert dummy data into country decoder table
INSERT INTO country_decoder (synonyms, iso2) VALUES (Array['spain'], 'ES');

-- This should return the point inserted above
SELECT cdb_geocoder_server.geocode_namedplace(session_user, txid_current(), 'Elx');
SELECT cdb_geocoder_server.geocode_namedplace(session_user, txid_current(), 'Elche');
SELECT cdb_geocoder_server.geocode_namedplace(session_user, txid_current(), 'Elx', 'Spain');
SELECT cdb_geocoder_server.geocode_namedplace(session_user, txid_current(), 'Elche', 'Spain');

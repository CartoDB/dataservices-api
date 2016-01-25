DROP FUNCTION IF EXISTS cdb_geocoder_server._get_redis_conf_v2(text);
DROP FUNCTION IF EXISTS cdb_geocoder_server._connect_to_redis(text);
DROP FUNCTION IF EXISTS cdb_geocoder_server._get_geocoder_config(text, text);
DROP FUNCTION IF EXISTS cdb_geocoder_server.cdb_geocode_street_point_v2(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_geocoder_server._cdb_here_geocode_street_point(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS cdb_geocoder_server._cdb_google_geocode_street_point(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
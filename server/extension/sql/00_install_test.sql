-- Install dependencies
CREATE EXTENSION postgis;
CREATE EXTENSION schema_triggers;
CREATE EXTENSION plpythonu;
CREATE EXTENSION cartodb;
CREATE EXTENSION cdb_geocoder;

-- Install the extension
CREATE EXTENSION cdb_geocoder_server;


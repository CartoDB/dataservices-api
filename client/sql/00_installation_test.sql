-- Install dependencies
CREATE EXTENSION postgis;
CREATE EXTENSION plproxy;

-- Install the extension
CREATE EXTENSION cdb_geocoder_client;

-- Mock the server connection to point to this very test db
SELECT cdb_geocoder_client._config_set('db_server_config', '{"connection_str": "dbname=contrib_regression host=127.0.0.1 user=postgres"}');

-- Mock the server schema
CREATE SCHEMA cdb_geocoder_server;

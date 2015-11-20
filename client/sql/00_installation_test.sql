-- Install dependencies
CREATE EXTENSION postgis;
CREATE EXTENSION schema_triggers;
CREATE EXTENSION plpythonu;
CREATE EXTENSION cartodb;
CREATE EXTENSION plproxy;

-- Install the extension
CREATE EXTENSION cdb_geocoder_client;

-- Mock the server connection to point to this very test db
SELECT cartodb.cdb_conf_setconf('geocoder_server_config', '{"connection_str": "dbname=contrib_regression host=127.0.0.1 user=postgres"}');
-- Mock the user configuration
SELECT cartodb.cdb_conf_setconf('user_config', '{"is_organization": false, "entity_name": "test_user"}');
-- Mock the geocoder configuration
SELECT cartodb.cdb_conf_setconf('geocoder_config', '{"street_geocoder_provider": "nokia","nokia_monthly_quota": 100, "nokia_soft_geocoder_limit": false}');

-- Mock the server schema
CREATE SCHEMA cdb_geocoder_server;

-- Create a test user to check permissions
DROP ROLE IF EXISTS test_regular_user;
CREATE ROLE test_regular_user;
GRANT publicuser TO test_regular_user;

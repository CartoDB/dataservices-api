--
-- This extension has its own table for configurations.
--
-- The table and the function are considered to be private and therefore
-- no permissions are granted for any other user but the creator.

CREATE TABLE IF NOT EXISTS _config ( KEY TEXT PRIMARY KEY, VALUE JSON NOT NULL );

-- Needed to dump config in backups
-- This can only be called from an SQL script executed by CREATE EXTENSION
SELECT pg_catalog.pg_extension_config_dump('_config', '');


CREATE OR REPLACE FUNCTION _config_set(key text, value JSON)
RETURNS VOID AS $$
BEGIN
    PERFORM _config_remove(key);
    EXECUTE 'INSERT INTO _config (KEY, VALUE) VALUES ($1, $2);' USING key, value;
END
$$ LANGUAGE PLPGSQL VOLATILE;


CREATE OR REPLACE FUNCTION _config_remove(key text)
RETURNS VOID AS $$
BEGIN
    EXECUTE 'DELETE FROM _config WHERE KEY = $1;' USING key;
END
$$ LANGUAGE PLPGSQL VOLATILE;

CREATE OR REPLACE FUNCTION _config_get(key text)
    RETURNS JSON AS $$
DECLARE
    value JSON;
BEGIN
    EXECUTE 'SELECT VALUE FROM _config WHERE KEY = $1;' INTO value USING key;
    RETURN value;
END
$$ LANGUAGE PLPGSQL STABLE;

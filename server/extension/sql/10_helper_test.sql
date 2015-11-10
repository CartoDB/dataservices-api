-- Create a conf table
CREATE TABLE conf (key TEXT NOT NULL PRIMARY KEY, values_json TEXT);
INSERT INTO conf VALUES ('cds', '{"Manolo Escobar": {"El Limonero":"En stock", "Viva el vino":"Sin stock"}}');

-- Test key retrieval
SELECT cdb_geocoder_server._get_conf('cds');

-- Test no key exception
SELECT cdb_geocoder_server._get_conf('no existe');

-- Drop conf table
DROP TABLE conf;

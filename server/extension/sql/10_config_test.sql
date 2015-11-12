-- Create a conf table
SELECT cdb_geocoder_server._config_set('cds', '{"Manolo Escobar": {"El Limonero":"En stock", "Viva el vino":"Sin stock"}}');

-- Test key retrieval
SELECT cdb_geocoder_server._config_get('cds');

-- Test returns NULL if key doesn't exist
SELECT cdb_geocoder_server._config_get('no existe');

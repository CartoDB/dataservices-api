-- Create a conf table
SELECT cartodb.cdb_conf_setconf('cds', '{"Manolo Escobar": {"El Limonero":"En stock", "Viva el vino":"Sin stock"}}');

-- Test key retrieval
SELECT cartodb.cdb_conf_getconf('cds');

-- Test returns NULL if key doesn't exist
SELECT cartodb.cdb_conf_getconf('no existe');

-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

CREATE TABLE my_table(the_geom geometry, cartodb_id int);

INSERT INTO my_table (cartodb_id) VALUES (1);

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_client.ds_fdw_metadata AS $$
BEGIN
  RETURN ('dummy_schema'::text, 'dummy_table'::text, 'dummy_server'::text);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_GetReturnMetadataOBS_GetMeasure(username text, orgname text, function_name text, params json)
RETURNS cdb_dataservices_client.ds_return_metadata AS $$
BEGIN
  RETURN (Array['total_pop'], Array['double precision']);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS RECORD AS $$
BEGIN
  RETURN (23.4::double precision, 1::int);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean AS $$
BEGIN
  RETURN true;
END;
$$ LANGUAGE 'plpgsql';

-- Mock again the function for it to return a different value now
CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS RECORD AS $$
BEGIN
  RETURN (577777.4::double precision, 1::int);
END;
$$ LANGUAGE 'plpgsql';

-- Augment a new table with total_pop
SELECT cdb_dataservices_client._DST_GetTableOBS_GetMeasure('my_table', 'my_table_new', '{"dummy":"dummy"}'::json);

-- Check that the table contains the new value for total_pop and not the value already existent in the table
SELECT * FROM my_table_new;

-- Clean tables
DROP TABLE my_table_new;
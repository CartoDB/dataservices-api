-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

CREATE TABLE my_table(cartodb_id int);

INSERT INTO my_table (cartodb_id) VALUES (1);

-- Mock the server functions
CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_client.ds_fdw_metadata AS $$
BEGIN
  RETURN ('dummy_schema'::text, 'dummy_table'::text, 'dummy_server'::text);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server._DST_GetReturnMetadata(username text, orgname text, function_name text, params json)
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

-- Create a sample user table
CREATE TABLE user_table (cartodb_id int, the_geom geometry);
INSERT INTO user_table(cartodb_id, the_geom) VALUES (1, '0101000020E6100000F74FC902E07D52C05FE24CC7654B4440');
INSERT INTO user_table(cartodb_id, the_geom) VALUES (2, '0101000020E6100000F74FC902E07D52C05FE24CC7654B4440');
INSERT INTO user_table(cartodb_id, the_geom) VALUES (3, '0101000020E6100000F74FC902E07D52C05FE24CC7654B4440');

-- Prepare a table with the total_pop column
SELECT cdb_dataservices_client._DST_PrepareTableOBS_GetMeasure('my_table_dst', '{"dummy":"dummy"}'::json);

-- The table should now exist and be empty
SELECT * FROM my_table_dst;

-- Populate the table with measurement data
SELECT cdb_dataservices_client._DST_PopulateTableOBS_GetMeasure('user_table', 'my_table_dst', '{"dummy":"dummy"}'::json);

-- The table should now show the results
SELECT * FROM my_table_dst;

-- Clean tables
DROP TABLE my_table_dst;
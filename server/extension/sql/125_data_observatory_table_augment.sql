CREATE TYPE ds_fdw_metadata as (schemaname text, tabname text, servername text);
CREATE TYPE ds_return_metadata as (colnames text[], coltypes text[]);


CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_ConnectUserTable(username text, useruuid text, input_schema text, dbname text, table_name text)
RETURNS ds_fdw_metadata AS $$
  ---- quota/checks and internal call to function
  --TODO: need username and orgname
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetReturnMetadata(params json)
RETURNS ds_return_metadata AS $$
  ---- quota/checks and internal call to function
  --TODO: need username and orgname
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_GetAugmentedColumns(table_schema text, table_name text, params json)
RETURNS SETOF record AS $$
  ---- quota/checks and internal call to function
  --TODO: need username and orgname
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server.OBS_DisconnectUserTable(table_schema text, table_name text, servername text)
RETURNS boolean AS $$
  ---- quota/checks and internal call to function
  --TODO: need username and orgname
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_ConnectUserTable(username text, useruuid text, input_schema text, dbname text, table_name text)
RETURNS ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    SELECT cdb_observatory._OBS_ConnectUserTable(username text, useruuid text, input_schema text, dbname text, host text, table_name text);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetReturnMetadata(params json)
RETURNS ds_return_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    SELECT cdb_observatory._OBS_GetReturnMetadata(params json);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetAugmentedColumns(table_schema text, table_name text, params json)
RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    SELECT cdb_observatory._OBS_GetReturnMetadata(params json);
$$ LANGUAGE plproxy;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_DisconnectUserTable(table_schema text, table_name text, servername text)
RETURNS boolean AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    SELECT cdb_observatory._OBS_DisconnectUserTable(table_schema text, table_name text, servername text);
$$ LANGUAGE plproxy;

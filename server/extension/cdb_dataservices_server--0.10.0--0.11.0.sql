--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.11.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
CREATE TYPE cdb_dataservices_server.ds_fdw_metadata as (schemaname text, tabname text, servername text);

CREATE TYPE cdb_dataservices_server.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    return plpy.execute("SELECT * FROM cdb_dataservices_server.__OBS_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, {schema}::text, {dbname}::text, {table_name}::text)"
        .format(username=plpy.quote_nullable(username), orgname=plpy.quote_nullable(orgname), user_db_role=plpy.quote_literal(user_db_role), schema=plpy.quote_literal(input_schema), dbname=plpy.quote_literal(dbname), table_name=plpy.quote_literal(table_name))
        )[0]
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.__OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_ConnectUserTable;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_dataservices_server.ds_return_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_GetReturnMetadata;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_FetchJoinFdwTableData;
$$ LANGUAGE plproxy;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_DisconnectUserTable;
$$ LANGUAGE plproxy;

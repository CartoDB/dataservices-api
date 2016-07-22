--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_server UPDATE TO '0.13.0'" to load this file. \quit

-- HERE goes your code to upgrade/downgrade
DROP FUNCTION IF EXISTS cdb_dataservices_server.__OBS_ConnectUserTable(text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION cdb_dataservices_server._OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    host_addr = plpy.execute("SELECT split_part(inet_client_addr()::text, '/', 1) as user_host")[0]['user_host']
    return plpy.execute("SELECT * FROM cdb_dataservices_server.__OBS_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, {schema}::text, {dbname}::text, {host_addr}::text, {table_name}::text)"
        .format(username=plpy.quote_nullable(username), orgname=plpy.quote_nullable(orgname), user_db_role=plpy.quote_literal(user_db_role), schema=plpy.quote_literal(input_schema), dbname=plpy.quote_literal(dbname), table_name=plpy.quote_literal(table_name), host_addr=plpy.quote_literal(host_addr))
        )[0]
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.__OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, host_addr text, table_name text)
RETURNS cdb_dataservices_server.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
    TARGET cdb_observatory._OBS_ConnectUserTable;
$$ LANGUAGE plproxy;


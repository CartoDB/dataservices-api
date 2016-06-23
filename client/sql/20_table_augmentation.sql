CREATE TYPE cdb_dataservices_client.ds_fdw_metadata as (schemaname text, tabname text, servername text);
CREATE TYPE cdb_dataservices_client.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_client.OBS_ProcessTable(table_name text, output_table_name text, params json)
RETURNS boolean AS $$
DECLARE
  username text;
  useruuid text;
  orgname text;
  dbname text;
  input_schema text;
  result boolean;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;

  SELECT session_user INTO useruuid;

  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument';
  END IF;

  IF orgname IS NULL OR orgname = '' OR orgname = '""' THEN
    input_schema := 'public';
  ELSE
    input_schema := username;
  END IF;

  SELECT current_database() INTO dbname;

  SELECT cdb_dataservices_client._OBS_ProcessTable(username, useruuid, input_schema, dbname, table_name, output_table_name, params) INTO result;
  

  RETURN result;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;



CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_ProcessTable(username text, useruuid text, input_schema text, dbname text, table_name text, output_table_name text, params json)
RETURNS boolean AS $$
    try:
        tabname = None
        # Obtain metadata for FDW connection
        ds_fdw_metadata = plpy.execute("SELECT schemaname, tabname, servername "
            "FROM cdb_dataservices_client._OBS_ConnectUserTable('{0}'::text, '{1}'::text, '{2}'::text, '{3}'::text, '{4}'::text);"
            .format(username, useruuid, input_schema, dbname, table_name))

        schemaname = ds_fdw_metadata[0]["schemaname"]
        tabname = ds_fdw_metadata[0]["tabname"]
        servername = ds_fdw_metadata[0]["servername"]

        # Obtain return types for augmentation procedure
        ds_return_metadata = plpy.execute("SELECT colnames, coltypes "
            "FROM cdb_dataservices_client._OBS_GetReturnMetadata('{0}'::json);"
            .format(params))

        colnames_array = ds_return_metadata[0]["colnames"]
        coltypes_array = ds_return_metadata[0]["coltypes"]

        # Populate a new table with the augmented results
        plpy.execute("CREATE TABLE {0} AS "
            "(SELECT results.{1}, user_table.* "
            "FROM {3} as user_table, "
            "cdb_dataservices_client._OBS_GetProcessedData('{2}'::text, '{3}'::text, '{4}'::json) as results({1} numeric, cartodb_id int) "
            "WHERE results.cartodb_id = user_table.cartodb_id)"
            .format(output_table_name, colnames_array[0] ,schemaname, tabname, params))

        plpy.execute('ALTER TABLE {0} OWNER TO "{1}";'
            .format(output_table_name, useruuid))

        # Wipe user FDW data from the server
        wiped = plpy.execute("SELECT cdb_dataservices_client._OBS_DisconnectUserTable('{0}'::text, '{1}'::text, '{2}'::text)"
            .format(schemaname, tabname, servername))

        return True
    except Exception as e:
        plpy.warning('Error trying to augment table {0}'.format(e))
        # Wipe user FDW data from the server in case of failure
        if tabname:
            wiped = plpy.execute("SELECT cdb_dataservices_client._OBS_DisconnectUserTable('{0}'::text, '{1}'::text, '{2}'::text)"
                .format(schemaname, tabname, servername))
        return False
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_ConnectUserTable(username text, useruuid text, input_schema text, dbname text, table_name text)
RETURNS ds_fdw_metadata AS $$
    CONNECT _server_conn_str();
    SELECT cdb_dataservices_server.OBS_ConnectUserTable(username text, useruuid text, input_schema text, dbname text, table_name text);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_GetReturnMetadata(params json)
RETURNS ds_return_metadata AS $$
    CONNECT _server_conn_str();
    SELECT cdb_dataservices_server.OBS_GetReturnMetadata(params json);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_GetProcessedData(table_schema text, table_name text, params json)
RETURNS SETOF record AS $$
    CONNECT _server_conn_str();
    TARGET cdb_dataservices_server.OBS_GetProcessedData;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_DisconnectUserTable(table_schema text, table_name text, server_name text)
RETURNS boolean AS $$
    CONNECT _server_conn_str();
    SELECT cdb_dataservices_server.OBS_DisconnectUserTable(table_schema text, table_name text, server_name text);
$$ LANGUAGE plproxy;

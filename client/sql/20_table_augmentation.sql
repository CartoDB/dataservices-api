CREATE TYPE cdb_dataservices_client.ds_fdw_metadata as (schemaname text, tabname text, servername text);
CREATE TYPE cdb_dataservices_client.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_PrepareTableOBS_GetMeasure(
    output_table_name text,
    params json
) RETURNS boolean AS $$
DECLARE
  username text;
  user_db_role text;
  orgname text;
  user_schema text;
  result boolean;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;

  SELECT session_user INTO user_db_role;

  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument';
  END IF;

  IF orgname IS NULL OR orgname = '' OR orgname = '""' THEN
    user_schema := 'public';
  ELSE
    user_schema := username;
  END IF;

  SELECT cdb_dataservices_client.__DST_PrepareTableOBS_GetMeasure(
      username,
      orgname,
      user_db_role,
      user_schema,
      output_table_name,
      params
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_PopulateTableOBS_GetMeasure(
    table_name text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
DECLARE
  username text;
  user_db_role text;
  orgname text;
  dbname text;
  user_schema text;
  result boolean;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;

  SELECT session_user INTO user_db_role;

  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument';
  END IF;

  IF orgname IS NULL OR orgname = '' OR orgname = '""' THEN
    user_schema := 'public';
  ELSE
    user_schema := username;
  END IF;

  SELECT current_database() INTO dbname;

  SELECT cdb_dataservices_client.__DST_PopulateTableOBS_GetMeasure(
      username,
      orgname,
      user_db_role,
      user_schema,
      dbname,
      table_name,
      output_table_name,
      params
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_dataservices_client.__DST_PrepareTableOBS_GetMeasure(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
    function_name = 'OBS_GetMeasure'
    # Obtain return types for augmentation procedure
    ds_return_metadata = plpy.execute("SELECT colnames, coltypes "
        "FROM cdb_dataservices_client._DST_GetReturnMetadata({username}::text, {orgname}::text, {function_name}::text, {params}::json, 200);"
        .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params)
            )
        )
    if ds_return_metadata[0]["colnames"]:
        colnames_arr = ds_return_metadata[0]["colnames"]
        coltypes_arr = ds_return_metadata[0]["coltypes"]
    else:
        raise Exception('Error retrieving OBS_GetMeasure metadata')


    # Prepare column and type strings required in the SQL queries
    columns_with_types_arr = [colnames_arr[i] + ' ' + coltypes_arr[i] for i in range(0,len(colnames_arr))]
    columns_with_types = ','.join(columns_with_types_arr)

    # Create a new table with the required columns
    plpy.execute('CREATE TABLE "{schema}".{table_name} ( '
        'cartodb_id int, the_geom geometry, {columns_with_types} '
        ');'
        .format(schema=user_schema, table_name=output_table_name, columns_with_types=columns_with_types)
        )

    plpy.execute('ALTER TABLE "{schema}".{table_name} OWNER TO "{user}";'
        .format(schema=user_schema, table_name=output_table_name, user=user_db_role)
        )

    return True
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.__DST_PopulateTableOBS_GetMeasure(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    dbname text,
    table_name text,
    output_table_name text,
    params json
) RETURNS boolean AS $$
    function_name = 'OBS_GetMeasure'

    numrows = plpy.execute(
        "SELECT count(*) as numrows "
        "FROM {user_schema}.{table_name} WHERE the_geom IS NOT null;" .format(
            user_schema=user_schema,
            table_name=table_name))[0]["numrows"]

    plpy.warning('Your dataset has {0} rows to be processed'.format(numrows))
    # Obtain return types for augmentation procedure
    ds_return_metadata = plpy.execute(
        "SELECT colnames, coltypes "
        "FROM cdb_dataservices_client._DST_GetReturnMetadata({username}::text, {orgname}::text, {function_name}::text, {params}::json, {numrows}::int);" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params),
            numrows=numrows))

    if ds_return_metadata[0]["colnames"]:
        colnames_arr = ds_return_metadata[0]["colnames"]
        coltypes_arr = ds_return_metadata[0]["coltypes"]
    else:
        raise Exception('Error retrieving OBS_GetMeasure metadata')

    # Prepare column and type strings required in the SQL queries
    columns_with_types_arr = [
        colnames_arr[i] +
        ' ' +
        coltypes_arr[i] for i in range(
            0,
            len(colnames_arr))]
    columns_with_types = ','.join(columns_with_types_arr)
    aliased_colname_list = ','.join(
        ['result.' + name for name in colnames_arr])

    # Instruct the OBS server side to establish a FDW
    # The metadata is obtained as well in order to:
    #   - (a) be able to write the query to grab the actual data to be executed in the remote server via pl/proxy,
    #   - (b) be able to tell OBS to free resources when done.
    ds_fdw_metadata = plpy.execute(
        "SELECT schemaname, tabname, servername "
        "FROM cdb_dataservices_client._DST_ConnectUserTable({username}::text, {orgname}::text, {user_db_role}::text, "
        "{schema}::text, {dbname}::text, {table_name}::text);" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            user_db_role=plpy.quote_literal(user_db_role),
            schema=plpy.quote_literal(user_schema),
            dbname=plpy.quote_literal(dbname),
            table_name=plpy.quote_literal(table_name)))

    if ds_fdw_metadata[0]["schemaname"]:
        server_schema = ds_fdw_metadata[0]["schemaname"]
        server_table_name = ds_fdw_metadata[0]["tabname"]
        server_name = ds_fdw_metadata[0]["servername"]
    else:
        raise Exception('Error connecting dataset via FDW')

    # Create a new table with the required columns
    plpy.execute(
        'INSERT INTO "{schema}".{analysis_table_name} '
        'SELECT ut.cartodb_id, ut.the_geom, {colname_list} '
        'FROM "{schema}".{table_name} ut '
        'LEFT JOIN _DST_FetchJoinFdwTableData({username}::text, {orgname}::text, {server_schema}::text, {server_table_name}::text, '
        '{function_name}::text, {params}::json) '
        'AS result ({columns_with_types}, cartodb_id int)  '
        'ON result.cartodb_id = ut.cartodb_id;' .format(
            schema=user_schema,
            analysis_table_name=output_table_name,
            colname_list=aliased_colname_list,
            table_name=table_name,
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            server_schema=plpy.quote_literal(server_schema),
            server_table_name=plpy.quote_literal(server_table_name),
            function_name=plpy.quote_literal(function_name),
            params=plpy.quote_literal(params),
            columns_with_types=columns_with_types))

    # Wipe user FDW data from the server
    wiped = plpy.execute(
        "SELECT cdb_dataservices_client._DST_DisconnectUserTable({username}::text, {orgname}::text, {server_schema}::text, "
        "{server_table_name}::text, {fdw_server}::text)" .format(
            username=plpy.quote_nullable(username),
            orgname=plpy.quote_nullable(orgname),
            server_schema=plpy.quote_literal(server_schema),
            server_table_name=plpy.quote_literal(server_table_name),
            fdw_server=plpy.quote_literal(server_name)))

    return True
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_ConnectUserTable(
    username text,
    orgname text,
    user_db_role text,
    user_schema text,
    dbname text,
    table_name text
)RETURNS cdb_dataservices_client.ds_fdw_metadata AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_ConnectUserTable;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_GetReturnMetadata(
    username text,
    orgname text,
    function_name text,
    params json,
    credits int
) RETURNS cdb_dataservices_client.ds_return_metadata AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_GetReturnMetadata;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_FetchJoinFdwTableData(
    username text,
    orgname text,
    table_schema text,
    table_name text,
    function_name text,
    params json
) RETURNS SETOF record AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_FetchJoinFdwTableData;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._DST_DisconnectUserTable(
    username text,
    orgname text,
    table_schema text,
    table_name text,
    server_name text
) RETURNS boolean AS $$
    CONNECT cdb_dataservices_client._server_conn_str();
    TARGET cdb_dataservices_server._DST_DisconnectUserTable;
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_dumpversion(username text, orgname text)
RETURNS text AS $$
  CONNECT cdb_dataservices_server._obs_server_conn_str(username, orgname);
  SELECT cdb_observatory.obs_dumpversion();
$$ LANGUAGE plproxy;

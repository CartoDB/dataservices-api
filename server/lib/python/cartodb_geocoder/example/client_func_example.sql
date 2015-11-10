# cdb_conf geocoder config example
INSERT INTO cdb_conf VALUES ('geocoder_conf', '{"geocoder_db": {"host": "localhost", "port": "5432", db": "cartodb_dev_user_274bf952-8568-4598-9efd-be92ed3d2ead_db", "user": "development_cartodb_user_274bf952-8568-4598-9efd-be92ed3d2ead"}, "redis": {"host": "localhost", "port": 6379, "db": 5 } }')

CREATE OR REPLACE FUNCTION cartodb._geocoder_admin0_polygons(search text)
    RETURNS Geometry AS
$$
    db_connection_str = plpy.execute("SELECT * FROM cartodb._Geocoder_Server_Conf() conf;")[0]['conf']
    return plpy.execute("SELECT cartodb._Geocoder_Admin0_Polygons('{0}', session_user, txid_current(), '{1}') as geom".format(search, db_connection_str))[0]['geom']
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE
FUNCTION cartodb._geocoder_server_conf()
    RETURNS text AS
$$
    conf = plpy.execute("SELECT cartodb.CDB_Conf_GetConf('geocoder_conf') conf")[0]['conf']
    if conf is None:
      raise "There is no geocoder server configuration "
    else:
      import json
      params = json.loads(conf)
      db_params = params['geocoder_db']
      return "host={0} port={1} dbname={2} user={3}".format(db_params['host'],db_params['port'],db_params['db'],db_params['user'])
$$ LANGUAGE 'plpythonu';

CREATE OR REPLACE FUNCTION cartodb._geocoder_admin0_polygons(search text, user_id name, tx_id bigint, db_connection_str text)
RETURNS Geometry AS $$
    CONNECT db_connection_str;
    SELECT geocode_admin0(search, tx_id, user_id);
$$ LANGUAGE plproxy;
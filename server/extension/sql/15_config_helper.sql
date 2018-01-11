CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_logger_config()
RETURNS boolean AS $$
  cache_key = "logger_config"
  if cache_key in GD:
    return False
  else:
    from cartodb_services.tools import LoggerConfig
    logger_config = LoggerConfig(plpy)
    GD[cache_key] = logger_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

-- This is done in order to avoid an undesired depedency on cartodb extension
CREATE OR REPLACE FUNCTION cdb_dataservices_server.cdb_conf_getconf(input_key text)
RETURNS JSON AS $$
    SELECT VALUE FROM cartodb.cdb_conf WHERE key = input_key;
$$ LANGUAGE SQL SECURITY DEFINER STABLE PARALLEL SAFE;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_SetConf(key text, value JSON)
    RETURNS void AS $$
BEGIN
    PERFORM cdb_dataservices_server.CDB_Conf_RemoveConf(key);
    EXECUTE 'INSERT INTO cartodb.CDB_CONF (KEY, VALUE) VALUES ($1, $2);' USING key, value;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER VOLATILE PARALLEL UNSAFE;

CREATE OR REPLACE
FUNCTION cdb_dataservices_server.CDB_Conf_RemoveConf(key text)
    RETURNS void AS $$
BEGIN
    EXECUTE 'DELETE FROM cartodb.CDB_CONF WHERE KEY = $1;' USING key;
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER VOLATILE PARALLEL UNSAFE ;


CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_geocoder_config(username text, orgname text, provider text DEFAULT NULL)
RETURNS boolean AS $$
  cache_key = "user_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import GeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    geocoder_config = GeocoderConfig(redis_conn, plpy, username, orgname, provider)
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_internal_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_internal_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import InternalGeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    geocoder_config = InternalGeocoderConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_isolines_routing_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_isolines_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import IsolinesRoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    isolines_routing_config = IsolinesRoutingConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = isolines_routing_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_routing_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_routing_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import RoutingConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    routing_config = RoutingConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = routing_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_obs_snapshot_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_obs_snapshot_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import ObservatorySnapshotConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    obs_snapshot_config = ObservatorySnapshotConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = obs_snapshot_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_obs_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_obs_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import ObservatoryConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    obs_config = ObservatoryConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = obs_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_dataservices_server._cdb_mapbox_apikey(
    username TEXT,
    orgname TEXT,
    service TEXT)
RETURNS TEXT AS $$
  import json
  from cartodb_services.mapbox.types import MAPBOX_ROUTING_APIKEY_ROUNDRROBIN, MAPBOX_GEOCODER_APIKEY_ROUNDRROBIN, MAPBOX_ISOLINES_APIKEY_ROUNDRROBIN

  if service == 'routing':
    round_robin_service = MAPBOX_ROUTING_APIKEY_ROUNDRROBIN
    api_keys = GD["user_routing_config_{0}".format(username)].mapbox_api_keys
  elif service == 'geocoder':
    round_robin_service = MAPBOX_GEOCODER_APIKEY_ROUNDRROBIN
    api_keys = GD["user_geocoder_config_{0}".format(username)].mapbox_api_keys
  elif service == 'isolines':
    round_robin_service = MAPBOX_ISOLINES_APIKEY_ROUNDRROBIN
    api_keys = GD["user_isolines_routing_config_{0}".format(username)].mapbox_matrix_api_keys
  else:
    return None

  round_robin = GD[round_robin_service] if round_robin_service in GD else 0

  api_key = api_keys[round_robin]

  GD[round_robin_service] = round_robin + 1 if round_robin < len(api_keys) - 1 else 0

  return api_key
$$ LANGUAGE plpythonu SECURITY DEFINER STABLE PARALLEL RESTRICTED;

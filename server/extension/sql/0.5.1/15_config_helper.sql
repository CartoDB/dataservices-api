-- Get the Redis configuration from the _conf table --
CREATE OR REPLACE FUNCTION cdb_dataservices_server._get_geocoder_config(username text, orgname text)
RETURNS boolean AS $$
  cache_key = "user_geocoder_config_{0}".format(username)
  if cache_key in GD:
    return False
  else:
    from cartodb_services.metrics import GeocoderConfig
    plpy.execute("SELECT cdb_dataservices_server._connect_to_redis('{0}')".format(username))
    redis_conn = GD["redis_connection_{0}".format(username)]['redis_metadata_connection']
    geocoder_config = GeocoderConfig(redis_conn, plpy, username, orgname)
    GD[cache_key] = geocoder_config
    return True
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- Get the Redis configuration from the _conf table --
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
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- Get the Redis configuration from the _conf table --
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
$$ LANGUAGE plpythonu SECURITY DEFINER;

-- Get the Redis configuration from the _conf table --
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

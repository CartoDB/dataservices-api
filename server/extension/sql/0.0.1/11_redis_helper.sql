-- Get the connection to redis from cache or create a new one
CREATE OR REPLACE FUNCTION cdb_geocoder_server._connect_to_redis(user_id name)
RETURNS boolean AS $$
  if user_id in GD and 'redis_connection' in GD[user_id]:
    return False
  else:
    from cartodb_geocoder import redis_helper
    redis_connection = redis_helper.RedisHelper('localhost', 6379, 5).redis_connection()
    GD[user_id] = {'redis_connection': redis_connection}
    return True
$$ LANGUAGE plpythonu;
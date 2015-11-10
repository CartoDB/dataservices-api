CREATE OR REPLACE
FUNCTION geocode_admin0(search text, tx_id bigint, user_id name)
  RETURNS Geometry AS
$$
  import logging
  from cartodb_geocoder import quota_service

  LOG_FILENAME = '/tmp/plpython.log'
  logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

  if user_id in SD and tx_id in SD[user_id] and 'redis_connection' in SD[user_id][tx_id]:
    logging.debug("Using redis cached connection...")
    qs = quota_service.QuotaService(logging, user_id, tx_id, redis_connection=SD[user_id][tx_id]['redis_connection'])
  else:
    qs = quota_service.QuotaService(logging, user_id, tx_id, redis_host='localhost', redis_port=6379, redis_db=5)

  if qs.check_user_quota():
    result = plpy.execute("SELECT geom FROM geocode_admin0_polygons(Array[\'{0}\']::text[])".format(search))
    if result.status() == 5 and result.nrows() == 1:
      qs.increment_georeference_use()
      SD[user_id] = {tx_id: {'redis_connection': qs.get_redis_connection()}}
      return result[0]["geom"]
    else:
      raise Exception('Something wrong with the georefence operation')
  else:
    raise Exception('Not enough quota for this user')

$$ LANGUAGE plpythonu;
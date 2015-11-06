CREATE OR REPLACE
FUNCTION geocode_admin0(search text, tx_id bigint, user_id name)
  RETURNS Geometry AS
$$
  import logging
  from sys import path
  path.append( '/home/ubuntu/www/cartodb-geocoder/server/lib/python/cartodb_geocoder' )
  import quota_service

  LOG_FILENAME = '/tmp/plpython.log'
  logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

  qs = quota_service.QuotaService(logging, user_id, tx_id)
  if qs.check_user_quota():
    result = plpy.execute("SELECT geom FROM geocode_admin0_polygons(Array[\'{0}\']::text[])".format(search))
    logging.debug("Number of rows: {0} --- Status: {1}".format(result.nrows(), result.status()))
    if result.status() == 5 and result.nrows() == 1:
      qs.increment_georeference_use()
      return result[0]["geom"]
    else:
      raise Exception('Something wrong with the georefence operation')
  else:
    raise Exception('Not enough quota for this user')
$$ LANGUAGE plpythonu;
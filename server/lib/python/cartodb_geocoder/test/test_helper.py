from datetime import datetime, date


def build_redis_user_config(redis_conn, username, quota=100, soft_limit=False,
                            service="heremaps",
                            end_date=datetime.today()):
    user_redis_name = "rails:users:{0}".format(username)
    redis_conn.hset(user_redis_name, 'soft_geocoding_limit', soft_limit)
    redis_conn.hset(user_redis_name, 'geocoding_quota', quota)
    redis_conn.hset(user_redis_name, 'geocoder_type', service)
    redis_conn.hset(user_redis_name, 'period_end_date', end_date)
    redis_conn.hset(user_redis_name, 'google_maps_client_id', '')
    redis_conn.hset(user_redis_name, 'google_maps_api_key', '')


def build_redis_org_config(redis_conn, orgname, quota=100,
                           end_date=datetime.today()):
    org_redis_name = "rails:orgs:{0}".format(orgname)
    redis_conn.hset(org_redis_name, 'geocoding_quota', quota)
    redis_conn.hset(org_redis_name, 'period_end_date', end_date)
    redis_conn.hset(org_redis_name, 'google_maps_client_id', '')
    redis_conn.hset(org_redis_name, 'google_maps_api_key', '')


def increment_geocoder_uses(redis_conn, username, orgname=None,
                            date=date.today(), service='geocoder_here',
                            metric='success_responses', amount=20):
    prefix = 'org' if orgname else 'user'
    entity_name = orgname if orgname else username
    yearmonth = date.strftime('%Y%m')
    redis_name = "{0}:{1}:{2}:{3}:{4}".format(prefix, entity_name,
                                              service, metric, yearmonth)
    redis_conn.zincrby(redis_name, date.day, amount)

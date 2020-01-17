from datetime import datetime, date
from dateutil.tz import tzlocal
from mock import Mock, MagicMock
import random
import sys
from mock_plpy import MockPlPy

plpy_mock = MockPlPy()
sys.modules['plpy'] = plpy_mock


def build_redis_user_config(redis_conn, username, service, quota=100,
                            soft_limit=False, provider="heremaps",
                            end_date=datetime.today()):
    end_date_tz = end_date.replace(tzinfo=tzlocal())
    user_redis_name = "rails:users:{0}".format(username)

    if service is 'geocoding':
        redis_conn.hset(user_redis_name, 'geocoder_provider', provider)
        redis_conn.hset(user_redis_name, 'geocoding_quota', str(quota))
        redis_conn.hset(user_redis_name, 'soft_geocoding_limit', str(soft_limit).lower())
    elif service is 'isolines':
        redis_conn.hset(user_redis_name, 'isolines_provider', provider)
        redis_conn.hset(user_redis_name, 'here_isolines_quota', str(quota))
        redis_conn.hset(user_redis_name, 'soft_here_isolines_limit', str(soft_limit).lower())
    elif service is 'routing':
        redis_conn.hset(user_redis_name, 'routing_provider', provider)
        redis_conn.hset(user_redis_name, 'mapzen_routing_quota', str(quota))
        redis_conn.hset(user_redis_name, 'soft_mapzen_routing_limit', str(soft_limit).lower())
    elif service is 'data_observatory':
        redis_conn.hset(user_redis_name, 'obs_general_quota', str(quota))
        redis_conn.hset(user_redis_name, 'soft_obs_general_limit', str(soft_limit).lower())

    redis_conn.hset(user_redis_name, 'google_maps_client_id', '')
    redis_conn.hset(user_redis_name, 'google_maps_api_key', '')
    redis_conn.hset(user_redis_name, 'period_end_date', end_date_tz.strftime("%Y-%m-%d %H:%M:%S %z"))


def build_redis_org_config(redis_conn, orgname, service, quota=100,
                           provider="heremaps", end_date=datetime.now(tzlocal())):
    org_redis_name = "rails:orgs:{0}".format(orgname)
    end_date_tz = end_date.replace(tzinfo=tzlocal())

    if service is 'geocoding':
        redis_conn.hset(org_redis_name, 'geocoder_provider', provider)
        if quota is not None:
            redis_conn.hset(org_redis_name, 'geocoding_quota', str(quota))
    elif service is 'isolines':
        redis_conn.hset(org_redis_name, 'isolines_provider', provider)
        if quota is not None:
            redis_conn.hset(org_redis_name, 'here_isolines_quota', str(quota))
    elif service is 'routing':
        redis_conn.hset(org_redis_name, 'routing_provider', provider)
        if quota is not None:
            redis_conn.hset(org_redis_name, 'mapzen_routing_quota', str(quota))
    elif service is 'data_observatory':
        if quota is not None:
            redis_conn.hset(org_redis_name, 'obs_general_quota', str(quota))

    redis_conn.hset(org_redis_name, 'google_maps_client_id', '')
    redis_conn.hset(org_redis_name, 'google_maps_api_key', '')
    redis_conn.hset(org_redis_name, 'period_end_date', end_date_tz.strftime("%Y-%m-%d %H:%M:%S %z"))


def increment_service_uses(redis_conn, username, orgname=None,
                           date=date.today(), service='geocoder_here',
                           metric='success_responses', amount=20):
    prefix = 'org' if orgname else 'user'
    entity_name = orgname if orgname else username
    yearmonth = date.strftime('%Y%m')
    redis_name = "{0}:{1}:{2}:{3}:{4}".format(prefix, entity_name,
                                              service, metric, yearmonth)
    redis_conn.zincrby(redis_name, date.strftime('%d'), amount)


def plpy_mock_config():
    plpy_mock._define_result("CDB_Conf_GetConf\('heremaps_conf'\)", [{'conf': '{"geocoder": {"app_id": "app_id", "app_code": "code", "geocoder_cost_per_hit": 1}, "isolines": {"app_id": "app_id", "app_code": "code"}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('mapzen_conf'\)", [{'conf': '{"routing": {"api_key": "api_key_rou", "monthly_quota": 1500000}, "geocoder": {"api_key": "api_key_geo", "monthly_quota": 1500000}, "matrix": {"api_key": "api_key_mat", "monthly_quota": 1500000}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('mapbox_conf'\)", [{'conf': '{"routing": {"api_keys": ["api_key_rou"], "monthly_quota": 1500000}, "geocoder": {"api_keys": ["api_key_geo"], "monthly_quota": 1500000}, "matrix": {"api_keys": ["api_key_mat"], "monthly_quota": 1500000}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('mapbox_iso_conf'\)", [{'conf': '{"isolines": {"api_keys": ["api_key_mat"], "monthly_quota": 1500000}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('tomtom_conf'\)", [{'conf': '{"routing": {"api_keys": ["api_key_rou"], "monthly_quota": 1500000}, "geocoder": {"api_keys": ["api_key_geo"], "monthly_quota": 1500000}, "isolines": {"api_keys": ["api_key_mat"], "monthly_quota": 1500000}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('logger_conf'\)", [{'conf': '{"geocoder_log_path": "/dev/null"}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('data_observatory_conf'\)", [{'conf': '{"connection": {"whitelist": ["ethervoid"], "production": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api", "staging": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api"}}'}])
    plpy_mock._define_result("CDB_Conf_GetConf\('server_conf'\)", [{'conf': '{"environment": "testing"}'}])
    plpy_mock._define_result("select txid_current", [{'txid': random.randint(0, 1000)}])

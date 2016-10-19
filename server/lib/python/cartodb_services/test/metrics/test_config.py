from unittest import TestCase
from mockredis import MockRedis
from cartodb_services.metrics import RoutingConfig
from ..test_helper import build_plpy_mock

class TestRoutingConfig(TestCase):

    def setUp(self):
        self._redis_conn = MockRedis()
        self._db_conn = build_plpy_mock()
        self._username = 'my_test_user'
        self._user_key = "rails:users:{0}".format(self._username)
        self._redis_conn.hset(self._user_key, 'period_end_date', '2016-10-10')

    def test_should_pick_quota_from_server_by_default(self):
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.monthly_quota == 1500000

    def test_should_pick_quota_from_redis_if_present(self):
        self._redis_conn.hset(self._user_key, 'mapzen_routing_quota', 1000)
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.monthly_quota == 1000

    def test_org_quota_overrides_user_quota(self):
        self._redis_conn.hset(self._user_key, 'mapzen_routing_quota', 1000)
        orgname = 'my_test_org'
        orgname_key = "rails:orgs:{0}".format(orgname)
        self._redis_conn.hset(orgname_key, 'period_end_date', '2016-05-31')
        self._redis_conn.hset(orgname_key, 'mapzen_routing_quota', 5000)

        # TODO: these are not too relevant for the routing config
        self._redis_conn.hset(orgname_key, 'geocoding_quota', 0)
        self._redis_conn.hset(orgname_key, 'here_isolines_quota', 0)

        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.monthly_quota == 5000


    def test_should_have_soft_limit_false_by_default(self):
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.soft_limit == False

    def test_can_set_soft_limit_in_user_conf(self):
        self._redis_conn.hset(self._user_key, 'soft_mapzen_routing_limit', True)
        orgname = None
        config = RoutingConfig(self._redis_conn, self._db_conn, self._username, orgname)
        assert config.soft_limit == True

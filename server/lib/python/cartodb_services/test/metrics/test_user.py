from unittest import TestCase
from cartodb_services.metrics import UserMetricsService
import datetime
from mockredis import MockRedis

class UserGeocoderConfig(object):

    def __init__(self, **kwargs):
        self.__dict__ = kwargs


class TestUserMetricsService(TestCase):

    def setUp(self):
        user_geocoder_config = UserGeocoderConfig(
            username = 'my_test_user',
            organization = None,
            period_end_date = datetime.date.today()
        )
        redis_conn = MockRedis()
        self.user_metrics_service = UserMetricsService(user_geocoder_config, redis_conn)


    def test_routing_used_quota_zero_when_no_usage(self):
        assert self.user_metrics_service.used_quota(UserMetricsService.SERVICE_MAPZEN_ROUTING, datetime.date.today()) == 0

    def test_routing_used_quota_counts_usages(self):
        self.user_metrics_service.increment_service_use(UserMetricsService.SERVICE_MAPZEN_ROUTING, 'success_responses')
        self.user_metrics_service.increment_service_use(UserMetricsService.SERVICE_MAPZEN_ROUTING, 'empty_responses')
        assert self.user_metrics_service.used_quota('routing_mapzen', datetime.date.today()) == 2

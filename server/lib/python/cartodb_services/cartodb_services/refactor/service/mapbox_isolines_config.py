from dateutil.parser import parse as date_parse
from cartodb_services.refactor.service.utils import round_robin
from cartodb_services.mapbox.types import MAPBOX_ISOLINES_APIKEY_ROUNDROBIN


class MapboxIsolinesConfig(object):
    """
    Configuration needed to operate the Mapbox directions service.
    """

    def __init__(self,
                 isolines_quota,
                 soft_isolines_limit,
                 period_end_date,
                 cost_per_hit,
                 log_path,
                 mapbox_api_keys,
                 username,
                 organization,
                 service_params,
                 GD):
        self._isolines_quota = isolines_quota
        self._soft_isolines_limit = soft_isolines_limit
        self._period_end_date = period_end_date
        self._cost_per_hit = cost_per_hit
        self._log_path = log_path
        self._mapbox_api_keys = mapbox_api_keys
        self._username = username
        self._organization = organization
        self._service_params = service_params
        self._GD = GD

    @property
    def service_type(self):
        return 'mapbox_isolines'

    @property
    def provider(self):
        return 'mapbox'

    @property
    def is_high_resolution(self):
        return True

    @property
    def isolines_quota(self):
        return self._isolines_quota

    @property
    def soft_isolines_limit(self):
        return self._soft_isolines_limit

    @property
    def period_end_date(self):
        return self._period_end_date

    @property
    def cost_per_hit(self):
        return self._cost_per_hit

    @property
    def log_path(self):
        return self._log_path

    @property
    def mapbox_api_key(self):
        return round_robin(self._mapbox_api_keys, self._GD,
                           MAPBOX_ISOLINES_APIKEY_ROUNDROBIN)

    @property
    def username(self):
        return self._username

    @property
    def organization(self):
        return self._organization

    @property
    def service_params(self):
        return self._service_params


class MapboxIsolinesConfigBuilder(object):

    def __init__(self, server_conf, user_conf, org_conf, username, orgname, GD):
        self._server_conf = server_conf
        self._user_conf = user_conf
        self._org_conf = org_conf
        self._username = username
        self._orgname = orgname
        self._GD = GD

    def get(self):
        mapbox_server_conf = self._server_conf.get('mapbox_conf')
        mapbox_api_keys = mapbox_server_conf['isolines']['api_keys']
        mapbox_service_params = mapbox_server_conf['isolines'].get('service', {})

        isolines_quota = self._get_quota()
        soft_isolines_limit = self._user_conf.get('soft_here_isolines_limit').lower() == 'true'
        cost_per_hit = 0
        period_end_date_str = self._org_conf.get('period_end_date') or self._user_conf.get('period_end_date')
        period_end_date = date_parse(period_end_date_str)

        logger_conf = self._server_conf.get('logger_conf')
        log_path = logger_conf.get('isolines_log_path', None)

        return MapboxIsolinesConfig(isolines_quota,
                                    soft_isolines_limit,
                                    period_end_date,
                                    cost_per_hit,
                                    log_path,
                                    mapbox_api_keys,
                                    self._username,
                                    self._orgname,
                                    mapbox_service_params,
                                    self._GD)

    def _get_quota(self):
        isolines_quota = self._org_conf.get('here_isolines_quota') or self._user_conf.get('here_isolines_quota')
        if isolines_quota is '':
            return 0

        return int(isolines_quota)

from dateutil.parser import parse as date_parse

class MapzenGeocoderConfig(object):
    """
    Value object that represents the configuration needed to operate the mapzen service.
    """

    def __init__(self,
                 geocoding_quota,
                 soft_geocoding_limit,
                 period_end_date,
                 cost_per_hit,
                 log_path,
                 mapzen_api_key,
                 username,
                 organization,
                 service_params):
        self._geocoding_quota = geocoding_quota
        self._soft_geocoding_limit = soft_geocoding_limit
        self._period_end_date = period_end_date
        self._cost_per_hit = cost_per_hit
        self._log_path = log_path
        self._mapzen_api_key = mapzen_api_key
        self._username = username
        self._organization = organization
        self._service_params = service_params

    # Kind of generic properties. Note which ones are for actually running the
    # service and which ones are needed for quota stuff.
    @property
    def service_type(self):
        return 'geocoder_mapzen'

    @property
    def provider(self):
        return 'mapzen'

    @property
    def is_high_resolution(self):
        return True

    @property
    def geocoding_quota(self):
        return self._geocoding_quota

    @property
    def soft_geocoding_limit(self):
        return self._soft_geocoding_limit

    @property
    def period_end_date(self):
        return self._period_end_date

    @property
    def cost_per_hit(self):
        return self._cost_per_hit

    # Server config, TODO: locate where this is actually used
    @property
    def log_path(self):
        return self._log_path

    # This is actually the specific one to run requests against the remote endpoitn
    @property
    def mapzen_api_key(self):
        return self._mapzen_api_key

    # These two identify the user
    @property
    def username(self):
        return self._username

    @property
    def organization(self):
        return self._organization

    @property
    def service_params(self):
        return self._service_params

    # TODO: for BW compat, remove
    @property
    def google_geocoder(self):
        return False


class MapzenGeocoderConfigBuilder(object):

    def __init__(self, server_conf, user_conf, org_conf, username, orgname):
        self._server_conf = server_conf
        self._user_conf = user_conf
        self._org_conf = org_conf
        self._username = username
        self._orgname = orgname

    def get(self):
        mapzen_server_conf = self._server_conf.get('mapzen_conf')
        mapzen_api_key = mapzen_server_conf['geocoder']['api_key']
        mapzen_service_params = mapzen_server_conf['geocoder'].get('service', {})

        geocoding_quota = self._get_quota(mapzen_server_conf)
        soft_geocoding_limit = self._user_conf.get('soft_geocoding_limit').lower() == 'true'
        cost_per_hit = 0
        period_end_date_str = self._org_conf.get('period_end_date') or self._user_conf.get('period_end_date')
        period_end_date = date_parse(period_end_date_str)

        logger_conf = self._server_conf.get('logger_conf')
        log_path = logger_conf.get('geocoder_log_path', None)

        return MapzenGeocoderConfig(geocoding_quota,
                                    soft_geocoding_limit,
                                    period_end_date,
                                    cost_per_hit,
                                    log_path,
                                    mapzen_api_key,
                                    self._username,
                                    self._orgname,
                                    mapzen_service_params)

    def _get_quota(self, mapzen_server_conf):
        geocoding_quota = self._org_conf.get('geocoding_quota') or self._user_conf.get('geocoding_quota')
        if geocoding_quota is '':
            return 0

        return int(geocoding_quota)

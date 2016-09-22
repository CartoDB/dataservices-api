from abc import ABCMeta, abstractproperty


class HiResGeocoderConfig(object):

    __metaclass__ = ABCMeta

    """
    This is actually an interface.
    Any class deriving from it must provide everything a geocoder may wish.
    """

    def __init__(self):
        self._geocoding_quota = None
        self._soft_geocoding_limit = None
        self._period_end_date = None
        self._cost_per_hit = None
        self._log_path = None

    @property
    def is_high_resolution(self):
        return True

    @abstractproperty
    def service_type(self):
        #TODO: rename to provider_name
        pass

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

    @property
    def log_path(self):
        return self._log_path

    #TODO: add method to check validity


class MapzenGeocoderConfig(HiResGeocoderConfig):

    """
    This is a class defining a "value object", with everything needed by the
    mapzen geocoder.
    """

    def __init__(self):
        super(HiResGeocoderConfig, self).__init__()
        self._mapzen_api_key = None

    @property
    def service_type(self):
        return 'geocoder_mapzen'

    @property
    def mapzen_api_key(self):
        return self._mapzen_api_key

    #TODO: add method to check validity


class MapzenGeocoderConfigFactory(object):

    def __init__(self, configs):
        self._configs = configs

    def get(self, user):
        """Returns a mapzen geocoder config object populated for a given user"""
        config = MapzenGeocoderConfig()

        mapzen_server_conf = self._configs.server_conf.get('mapzen_conf')
        config._geocoding_quota = mapzen_server_conf['geocoder']['monthly_quota']

        config._soft_geocoding_limit = self._configs.user_config.get('soft_geocoding_limit')

        if user.is_org_user:
            config._period_end_date = self._configs.org_config.get('period_end_date')
        else:
            config._period_end_date = self._configs.user_config.get('period_end_date')

        config._cost_per_hit = 0

        logger_conf = self._configs.server_config.get('logger_conf')
        self._log_path = logger_conf['geocoder_log_path']
        # TODO: call check for validity
        return config


class GeocoderProviderFactory(object):

    GEOCODER_PROVIDER_KEY = 'geocoder_provider_key'
    DEFAULT_PROVIDER = 'mapzen'

    def __init__(self, configs):
        self._configs = configs

    def get(user):
        # TODO: IMHO this should be a common pattern for all configs
        # NOTE: I have mixed filligs about the defaults.
        server_provider = _configs.server_config.get(GEOCODER_PROVIDER_KEY)
        user_provider = _configs.user_config.get(GEOCODER_PROVIDER_KEY)
        org_provider = _configs.org_config.get(GEOCODER_PROVIDER_KEY)

        effective_provider = server_provider or user_provider or org_provider or DEFAULT_PROVIDER
        return effective_provider



class HiResGeocoderConfig(object):

    def __init__(self, configs):
        self._configs = configs

    def get(self, user):
        """Returns a concrete config object, depending on the provider set in the config"""
        #TODO: implement GeocoderProviderFactory
        provider = GeocoderProviderFactory(self._configs).get(user)
        if provider == 'mapzen':
            config = MapzenGeocoderConfigFactory(configs).get(user)
        else:
            #TODO: implement other providers
            raise NotImplementedError('Not implemented yet %s' % provider)
        return config

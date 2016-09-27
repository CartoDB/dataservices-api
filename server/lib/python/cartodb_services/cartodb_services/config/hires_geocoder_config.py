from abc import ABCMeta, abstractproperty
from dateutil.parser import parse as date_parse


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
        # This is meant to be: geocoder_mapzen, geocoder_here, etc.
        pass

    @abstractproperty
    def provider(self):
        # This is meant to be: mapzen, here, etc.
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
    def provider(self):
        return 'mapzen'

    @property
    def mapzen_api_key(self):
        return self._mapzen_api_key

    # TODO: this is a hack for backwards compat, probably to be removed
    @property
    def username(self):
        return self._username

    # TODO: this is a hack for backwards compat, probably to be removed
    @property
    def organization(self):
        return self._organization

    #TODO: add method to check validity


class MapzenGeocoderConfigFactory(object):

    def __init__(self, configs):
        self._configs = configs

    def get(self, user):
        """Returns a mapzen geocoder config object populated for a given user"""
        config = MapzenGeocoderConfig()

        mapzen_server_conf = self._configs.server_config.get('mapzen_conf')
        config._geocoding_quota = mapzen_server_conf['geocoder']['monthly_quota']
        config._mapzen_api_key = mapzen_server_conf['geocoder']['api_key']

        config._soft_geocoding_limit = self._configs.user_config.get('soft_geocoding_limit')

        if user.is_org_user:
            period_end_date_str = self._configs.org_config.get('period_end_date')
        else:
            period_end_date_str = self._configs.user_config.get('period_end_date')
        config._period_end_date = date_parse(period_end_date_str)

        config._cost_per_hit = 0

        logger_conf = self._configs.server_config.get('logger_conf')
        config._log_path = logger_conf['geocoder_log_path']

        config._username = user.username
        config._organization = user.orgname
        # TODO: call check for validity
        return config


# TODO: move this to another file
class GeocoderProviderFactory(object):

    GEOCODER_PROVIDER_KEY = 'geocoder_provider'
    DEFAULT_PROVIDER = 'mapzen'

    def __init__(self, configs):
        self._configs = configs

    def get(self):
        # TODO: IMHO this should be a common pattern for all configs
        # NOTE: I have mixed filligs about the defaults.
        server_provider = self._configs.server_config.get(self.GEOCODER_PROVIDER_KEY)
        user_provider = self._configs.user_config.get(self.GEOCODER_PROVIDER_KEY)
        org_provider = self._configs.org_config.get(self.GEOCODER_PROVIDER_KEY)

        effective_provider = server_provider or user_provider or org_provider or self.DEFAULT_PROVIDER
        return effective_provider



class HiResGeocoderConfigFactory(object):

    def __init__(self, configs):
        self._configs = configs

    def get(self, user):
        """Returns a concrete config object, depending on the provider set in the config"""
        provider = GeocoderProviderFactory(self._configs).get()
        if provider == 'mapzen':
            config = MapzenGeocoderConfigFactory(self._configs).get(user)
        else:
            #TODO: implement other providers
            raise NotImplementedError('Not implemented yet %s' % provider)
        return config

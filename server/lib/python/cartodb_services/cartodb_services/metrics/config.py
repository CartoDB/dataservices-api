import json
import abc
from dateutil.parser import parse as date_parse


class ConfigException(Exception):
    pass


class ServiceConfig(object):
    __metaclass__ = abc.ABCMeta

    def __init__(self, redis_connection, username, orgname=None):
        self._redis_connection = redis_connection
        self._username = username
        self._orgname = orgname

    @abc.abstractproperty
    def service_type(self):
        raise NotImplementedError('service_type property must be defined')

    @property
    def username(self):
        return self._username

    @property
    def organization(self):
        return self._orgname


class IsolinesRoutingConfig(ServiceConfig):

    ROUTING_CONFIG_KEYS = ['here_isolines_quota', 'soft_here_isolines_limit',
                           'period_end_date', 'username', 'orgname',
                           'heremaps_app_id', 'heremaps_app_code', 'geocoder_type']
    NOKIA_APP_ID_KEY = 'heremaps_app_id'
    NOKIA_APP_CODE_KEY = 'heremaps_app_code'
    QUOTA_KEY = 'here_isolines_quota'
    SOFT_LIMIT_KEY = 'soft_here_isolines_limit'
    USERNAME_KEY = 'username'
    ORGNAME_KEY = 'orgname'
    PERIOD_END_DATE = 'period_end_date'
    GEOCODER_TYPE_KEY = 'geocoder_type'
    GOOGLE_GEOCODER = 'google'

    def __init__(self, redis_connection, username, orgname=None,
                 heremaps_app_id=None, heremaps_app_code=None):
        super(IsolinesRoutingConfig, self).__init__(redis_connection, username,
                                             orgname)
        config = self.__get_user_config(username, orgname, heremaps_app_id,
                                        heremaps_app_code)
        filtered_config = {key: config[key] for key in self.ROUTING_CONFIG_KEYS if key in config.keys()}
        self.__parse_config(filtered_config)

    def __get_user_config(self, username, orgname=None, heremaps_app_id=None,
                          heremaps_app_code=None):
        user_config = self._redis_connection.hgetall(
            "rails:users:{0}".format(username))
        if not user_config:
            raise ConfigException("""There is no user config available. Please check your configuration.'""")
        else:
            user_config[self.NOKIA_APP_ID_KEY] = heremaps_app_id
            user_config[self.NOKIA_APP_CODE_KEY] = heremaps_app_code
            if orgname:
                self.__get_organization_config(orgname, user_config)

            return user_config

    def __get_organization_config(self, orgname, user_config):
        org_config = self._redis_connection.hgetall(
            "rails:orgs:{0}".format(orgname))
        if not org_config:
            raise ConfigException("""There is no organization config available. Please check your configuration.'""")
        else:
            user_config[self.QUOTA_KEY] = org_config[self.QUOTA_KEY]
            user_config[self.PERIOD_END_DATE] = org_config[self.PERIOD_END_DATE]

    def __parse_config(self, filtered_config):
        self._geocoder_type = filtered_config[self.GEOCODER_TYPE_KEY].lower()
        self._isolines_quota = float(filtered_config[self.QUOTA_KEY])
        self._period_end_date = date_parse(filtered_config[self.PERIOD_END_DATE])
        if filtered_config[self.SOFT_LIMIT_KEY].lower() == 'true':
            self._soft_isolines_limit = True
        else:
            self._soft_isolines_limit = False
        self._heremaps_app_id = filtered_config[self.NOKIA_APP_ID_KEY]
        self._heremaps_app_code = filtered_config[self.NOKIA_APP_CODE_KEY]

    @property
    def service_type(self):
        return 'here_isolines'

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
    def heremaps_app_id(self):
        return self._heremaps_app_id

    @property
    def heremaps_app_code(self):
        return self._heremaps_app_code

    @property
    def google_services_user(self):
        return self._geocoder_type == self.GOOGLE_GEOCODER


class InternalGeocoderConfig(ServiceConfig):

    def __init__(self, redis_connection, username, orgname=None):
        super(InternalGeocoderConfig, self).__init__(redis_connection,
                                                     username, orgname)

    @property
    def service_type(self):
        return 'geocoder_internal'


class GeocoderConfig(ServiceConfig):

    GEOCODER_CONFIG_KEYS = ['google_maps_client_id', 'google_maps_api_key',
                            'geocoding_quota', 'soft_geocoding_limit',
                            'geocoder_type', 'period_end_date',
                            'heremaps_app_id', 'heremaps_app_code', 'username',
                            'orgname']
    NOKIA_GEOCODER_MANDATORY_KEYS = ['geocoding_quota', 'soft_geocoding_limit',
                                     'heremaps_app_id', 'heremaps_app_code']
    NOKIA_GEOCODER = 'heremaps'
    NOKIA_GEOCODER_APP_ID_KEY = 'heremaps_app_id'
    NOKIA_GEOCODER_APP_CODE_KEY = 'heremaps_app_code'
    GOOGLE_GEOCODER = 'google'
    GOOGLE_GEOCODER_API_KEY = 'google_maps_api_key'
    GOOGLE_GEOCODER_CLIENT_ID = 'google_maps_client_id'
    GEOCODER_TYPE = 'geocoder_type'
    QUOTA_KEY = 'geocoding_quota'
    SOFT_LIMIT_KEY = 'soft_geocoding_limit'
    USERNAME_KEY = 'username'
    ORGNAME_KEY = 'orgname'
    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_connection, username, orgname=None,
                 heremaps_app_id=None, heremaps_app_code=None):
        super(GeocoderConfig, self).__init__(redis_connection, username,
                                             orgname)
        config = self.__get_user_config(username, orgname, heremaps_app_id,
                                        heremaps_app_code)
        filtered_config = {key: config[key] for key in self.GEOCODER_CONFIG_KEYS if key in config.keys()}
        self.__check_config(filtered_config)
        self.__parse_config(filtered_config)

    def __get_user_config(self, username, orgname=None, heremaps_app_id=None,
                          heremaps_app_code=None):
        user_config = self._redis_connection.hgetall(
            "rails:users:{0}".format(username))
        if not user_config:
            raise ConfigException("""There is no user config available. Please check your configuration.'""")
        else:
            user_config[self.NOKIA_GEOCODER_APP_ID_KEY] = heremaps_app_id
            user_config[self.NOKIA_GEOCODER_APP_CODE_KEY] = heremaps_app_code
            if orgname:
                self.__get_organization_config(orgname, user_config)

            return user_config

    def __get_organization_config(self, orgname, user_config):
        org_config = self._redis_connection.hgetall(
            "rails:orgs:{0}".format(orgname))
        if not org_config:
            raise ConfigException("""There is no organization config available. Please check your configuration.'""")
        else:
            user_config[self.QUOTA_KEY] = org_config[self.QUOTA_KEY]
            user_config[self.PERIOD_END_DATE] = org_config[self.PERIOD_END_DATE]
            user_config[self.GOOGLE_GEOCODER_CLIENT_ID] = org_config[self.GOOGLE_GEOCODER_CLIENT_ID]
            user_config[self.GOOGLE_GEOCODER_API_KEY] = org_config[self.GOOGLE_GEOCODER_API_KEY]

    def __check_config(self, filtered_config):
        if filtered_config[self.GEOCODER_TYPE].lower() == self.NOKIA_GEOCODER:
            if not set(self.NOKIA_GEOCODER_MANDATORY_KEYS).issubset(set(filtered_config.keys())):
                raise ConfigException("""Some mandatory parameter/s for Nokia geocoder are missing. Check it please""")
            if not filtered_config[self.NOKIA_GEOCODER_APP_ID_KEY] or not filtered_config[self.NOKIA_GEOCODER_APP_CODE_KEY]:
                raise ConfigException("""Nokia geocoder configuration is missing. Check it please""")
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
            if self.GOOGLE_GEOCODER_API_KEY not in filtered_config.keys():
                raise ConfigException("""Google geocoder need the mandatory parameter 'google_maps_private_key'""")

        return True

    def __parse_config(self, filtered_config):
        self._geocoder_type = filtered_config[self.GEOCODER_TYPE].lower()
        self._geocoding_quota = float(filtered_config[self.QUOTA_KEY])
        self._period_end_date = date_parse(filtered_config[self.PERIOD_END_DATE])
        if filtered_config[self.SOFT_LIMIT_KEY].lower() == 'true':
            self._soft_geocoding_limit = True
        else:
            self._soft_geocoding_limit = False
        if filtered_config[self.GEOCODER_TYPE].lower() == self.NOKIA_GEOCODER:
            self._heremaps_app_id = filtered_config[self.NOKIA_GEOCODER_APP_ID_KEY]
            self._heremaps_app_code = filtered_config[self.NOKIA_GEOCODER_APP_CODE_KEY]
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
            self._google_maps_api_key = filtered_config[self.GOOGLE_GEOCODER_API_KEY]
            self._google_maps_client_id = filtered_config[self.GOOGLE_GEOCODER_CLIENT_ID]

    @property
    def service_type(self):
        if self._geocoder_type == self.GOOGLE_GEOCODER:
            return 'geocoder_google'
        else:
            return 'geocoder_here'

    @property
    def heremaps_geocoder(self):
        return self._geocoder_type == self.NOKIA_GEOCODER

    @property
    def google_geocoder(self):
        return self._geocoder_type == self.GOOGLE_GEOCODER

    @property
    def google_client_id(self):
        return self._google_maps_client_id

    @property
    def google_api_key(self):
        return self._google_maps_api_key

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
    def heremaps_app_id(self):
        return self._heremaps_app_id

    @property
    def heremaps_app_code(self):
        return self._heremaps_app_code

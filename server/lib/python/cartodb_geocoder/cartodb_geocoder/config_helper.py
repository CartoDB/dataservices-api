import json
from dateutil.parser import parse as date_parse


class ConfigException(Exception):
    pass


class GeocoderConfig:

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
        self._redis_connection = redis_connection
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
            user_config[self.USERNAME_KEY] = username
            user_config[self.ORGNAME_KEY] = orgname
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
        self._username = filtered_config[self.USERNAME_KEY].lower()
        if filtered_config[self.ORGNAME_KEY]:
            self._orgname = filtered_config[self.ORGNAME_KEY].lower()
        else:
            self._orgname = None
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

    @property
    def username(self):
        return self._username

    @property
    def organization(self):
        return self._orgname

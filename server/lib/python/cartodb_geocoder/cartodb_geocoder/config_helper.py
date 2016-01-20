import json
from dateutil.parser import parse as date_parse


class ConfigException(Exception):
    pass


class UserConfig:

    USER_CONFIG_KEYS = ['is_organization', 'entity_name']

    def __init__(self, user_config_json, db_user_id=None):
        config = json.loads(user_config_json)
        filtered_config = {key: config[key] for key in self.USER_CONFIG_KEYS if key in config.keys()}
        self.__check_config(filtered_config)
        self.__parse_config(filtered_config)

    def __check_config(self, filtered_config):
        if len(filtered_config.keys()) != len(self.USER_CONFIG_KEYS):
            raise ConfigException(
                "Passed user configuration is not correct, check it please")

        return True

    @property
    def is_organization(self):
        return self._is_organization

    @property
    def entity_name(self):
        return self._entity_name

    def __parse_config(self, filtered_config):
        self._is_organization = filtered_config['is_organization']
        self._entity_name = filtered_config['entity_name']


class GeocoderConfig:

    GEOCODER_CONFIG_KEYS = ['google_maps_client_id', 'google_maps_api_key',
                            'geocoding_quota', 'soft_geocoding_limit',
                            'geocoder_type', 'period_end_date']
    NOKIA_GEOCODER_MANDATORY_KEYS = ['geocoding_quota', 'soft_geocoding_limit']
    NOKIA_GEOCODER = 'heremaps'
    GOOGLE_GEOCODER = 'google'
    GOOGLE_GEOCODER_API_KEY = 'google_maps_api_key'
    GOOGLE_GEOCODER_CLIENT_ID = 'google_maps_client_id'
    GEOCODER_TYPE = 'geocoder_type'
    QUOTA_KEY = 'geocoding_quota'
    SOFT_LIMIT_KEY = 'soft_geocoding_limit'
    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_connection, username, orgname=None):
        self._redis_connection = redis_connection
        config = self.__get_user_config(username, orgname)
        filtered_config = {key: config[key] for key in self.GEOCODER_CONFIG_KEYS if key in config.keys()}
        self.__check_config(filtered_config)
        self.__parse_config(filtered_config)

    def __get_user_config(self, username, orgname=None):
        user_config = self._redis_connection.hgetall(
            "rails:users:{0}".format(username))
        if orgname:
            org_config = self._redis_connection.hgetall(
                "rails:orgs:{0}".format(orgname))
            user_config[self.QUOTA_KEY] = org_config[self.QUOTA_KEY]
            user_config[self.PERIOD_END_DATE] = org_config[self.PERIOD_END_DATE]
            user_config[self.GOOGLE_GEOCODER_CLIENT_ID] = org_config[self.GOOGLE_GEOCODER_CLIENT_ID]
            user_config[self.GOOGLE_GEOCODER_API_KEY] = org_config[self.GOOGLE_GEOCODER_API_KEY]

        return user_config

    def __check_config(self, filtered_config):
        if filtered_config[self.GEOCODER_TYPE].lower() == self.NOKIA_GEOCODER:
            if not set(self.NOKIA_GEOCODER_MANDATORY_KEYS).issubset(set(filtered_config.keys())):
                raise ConfigException("""Nokia geocoder needs the mandatory parameters '' and 'nokia_soft_geocoder_limit'""")
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
            if self.GOOGLE_GEOCODER_API_KEY not in filtered_config.keys():
                raise ConfigException("Google geocoder need the mandatory parameter 'google_maps_private_key'")

        return True

    def __parse_config(self, filtered_config):
        self._geocoder_type = filtered_config[self.GEOCODER_TYPE].lower()
        self._period_end_date = date_parse(filtered_config[self.PERIOD_END_DATE])
        self._google_maps_private_key = None
        self._nokia_monthly_quota = 0
        self._nokia_soft_geocoder_limit = False
        if self.GOOGLE_GEOCODER == self._geocoder_type:
            self._google_maps_private_key = filtered_config[self.GOOGLE_GEOCODER_API_KEY]
            self._google_maps_client_id = filtered_config[self.GOOGLE_GEOCODER_CLIENT_ID]
        elif self.NOKIA_GEOCODER == self._geocoder_type:
            self._geocoding_quota = filtered_config[self.QUOTA_KEY]
            self._soft_geocoding_limit = filtered_config[self.SOFT_LIMIT_KEY]

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
        return self._google_maps_private_key

    @property
    def geocoding_quota(self):
        return self._geocoding_quota

    @property
    def soft_geocoding_limit(self):
        return self._soft_geocoding_limit

    @property
    def period_end_date(self):
        return self._period_end_date

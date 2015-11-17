import json

class ConfigException(Exception):
    pass

class UserConfig:

  USER_CONFIG_KEYS = ['is_organization', 'entity_name']

  def __init__(self, user_config_json):
    config = json.loads(user_config_json)
    filtered_config = { key: config[key] for key in self.USER_CONFIG_KEYS if key in config.keys() }
    self.__check_config(filtered_config)
    self.__parse_config(filtered_config)

  def __check_config(self, filtered_config):
    if len(filtered_config.keys()) != len(self.USER_CONFIG_KEYS):
      raise ConfigException("Passed user configuration is not correct, check it please")

    return True

  def __parse_config(self, filtered_config):
    self._is_organization = filtered_config['is_organization']
    self._entity_name = filtered_config['entity_name']

  @property
  def is_organization(self):
    return self._is_organization

  @property
  def entity_name(self):
    return self._entity_name

class GeocoderConfig:

  GEOCODER_CONFIG_KEYS = ['street_geocoder_provider', 'google_maps_private_key',
    'nokia_monthly_quota', 'nokia_soft_geocoder_limit']
  NOKIA_GEOCODER_MANDATORY_KEYS = ['nokia_monthly_quota', 'nokia_soft_geocoder_limit']
  NOKIA_GEOCODER = 'nokia'
  NOKIA_QUOTA_KEY = 'nokia_monthly_quota'
  NOKIA_SOFT_LIMIT_KEY = 'nokia_soft_geocoder_limit'
  GOOGLE_GEOCODER = 'google'
  GEOCODER_TYPE = 'street_geocoder_provider'
  GOOGLE_GEOCODER_API_KEY = 'google_maps_private_key'

  def __init__(self, geocoder_config_json):
    config = json.loads(geocoder_config_json)
    filtered_config = { key: config[key] for key in self.GEOCODER_CONFIG_KEYS if key in config.keys() }
    self.__check_config(filtered_config)
    self.__parse_config(filtered_config)

  def __check_config(self, filtered_config):
    if filtered_config[self.GEOCODER_TYPE].lower() == self.NOKIA_GEOCODER:
      if not set(self.NOKIA_GEOCODER_MANDATORY_KEYS).issubset(set(filtered_config.keys())):
        raise ConfigException("""Nokia geocoder need the mandatory parameters 'nokia_monthly_quota' and 'nokia_soft_geocoder_limit'""")
    elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
      if self.GOOGLE_GEOCODER_API_KEY not in filtered_config.keys():
        raise ConfigException("Google geocoder need the mandatory parameter 'google_maps_private_key'")

    return True

  def __parse_config(self, filtered_config):
    self._geocoder_type = filtered_config[self.GEOCODER_TYPE].lower()
    self._google_maps_private_key = None
    self._nokia_monthly_quota = 0
    self._nokia_soft_geocoder_limit = False
    if self.GOOGLE_GEOCODER == self._geocoder_type:
      self._google_maps_private_key = filtered_config[self.GOOGLE_GEOCODER_API_KEY]
    elif self.NOKIA_GEOCODER == self._geocoder_type:
      self._nokia_monthly_quota = filtered_config[self.NOKIA_QUOTA_KEY]
      self._nokia_soft_geocoder_limit = filtered_config[self.NOKIA_SOFT_LIMIT_KEY]

  @property
  def nokia_geocoder(self):
    return self._geocoder_type == self.NOKIA_GEOCODER

  @property
  def google_geocoder(self):
    return self._geocoder_type == self.GOOGLE_GEOCODER

  @property
  def google_api_key(self):
    return self._google_maps_private_key

  @property
  def nokia_monthly_quota(self):
    return self._nokia_monthly_quota

  @property
  def nokia_soft_limit(self):
    return self._nokia_soft_geocoder_limit
import json
import abc
from dateutil.parser import parse as date_parse


class ConfigException(Exception):
    pass


class ServiceConfig(object):
    __metaclass__ = abc.ABCMeta

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        self._redis_connection = redis_connection
        self._username = username
        self._orgname = orgname
        self._db_config = ServicesDBConfig(db_conn)
        if redis_connection:
            self._redis_config = ServicesRedisConfig(redis_connection).build(username, orgname)
        else:
            self._redis_config = None

    @abc.abstractproperty
    def service_type(self):
        raise NotImplementedError('service_type property must be defined')

    @property
    def username(self):
        return self._username

    @property
    def organization(self):
        return self._orgname

class DataObservatoryConfig(ServiceConfig):

    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        super(DataObservatoryConfig, self).__init__(redis_connection, db_conn,
                                            username, orgname)
        self._monthly_quota = self._db_config.data_observatory_monthly_quota
        self._period_end_date = date_parse(self._redis_config[self.PERIOD_END_DATE])

    @property
    def service_type(self):
        return 'data_observatory'

    @property
    def monthly_quota(self):
        return self._monthly_quota

    @property
    def period_end_date(self):
        return self._period_end_date


class RoutingConfig(ServiceConfig):

    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        super(RoutingConfig, self).__init__(redis_connection, db_conn,
                                            username, orgname)
        self._mapzen_api_key = self._db_config.mapzen_routing_api_key
        self._monthly_quota = self._db_config.mapzen_routing_monthly_quota
        self._period_end_date = date_parse(self._redis_config[self.PERIOD_END_DATE])

    @property
    def service_type(self):
        return 'routing_mapzen'

    @property
    def mapzen_api_key(self):
        return self._mapzen_api_key

    @property
    def monthly_quota(self):
        return self._monthly_quota

    @property
    def period_end_date(self):
        return self._period_end_date


class IsolinesRoutingConfig(ServiceConfig):

    ROUTING_CONFIG_KEYS = ['here_isolines_quota', 'soft_here_isolines_limit',
                           'period_end_date', 'username', 'orgname',
                           'heremaps_isolines_app_id', 'heremaps_isolines_app_code',
                           'geocoder_type']
    QUOTA_KEY = 'here_isolines_quota'
    SOFT_LIMIT_KEY = 'soft_here_isolines_limit'
    PERIOD_END_DATE = 'period_end_date'
    GEOCODER_TYPE_KEY = 'geocoder_type'
    GOOGLE_GEOCODER = 'google'

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        super(IsolinesRoutingConfig, self).__init__(redis_connection, db_conn,
                                                    username, orgname)
        filtered_config = {key: self._redis_config[key] for key in self.ROUTING_CONFIG_KEYS if key in self._redis_config.keys()}
        self.__parse_config(filtered_config, self._db_config)

    def __parse_config(self, filtered_config, db_config):
        self._geocoder_type = filtered_config[self.GEOCODER_TYPE_KEY].lower()
        self._isolines_quota = float(filtered_config[self.QUOTA_KEY])
        self._period_end_date = date_parse(filtered_config[self.PERIOD_END_DATE])
        if filtered_config[self.SOFT_LIMIT_KEY].lower() == 'true':
            self._soft_isolines_limit = True
        else:
            self._soft_isolines_limit = False
        self._heremaps_app_id = db_config.heremaps_isolines_app_id
        self._heremaps_app_code = db_config.heremaps_isolines_app_code

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

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        # For now, internal geocoder doesn't use the redis config
        super(InternalGeocoderConfig, self).__init__(None, db_conn,
                                                     username, orgname)
        self._log_path = self._db_config.geocoder_log_path

    @property
    def service_type(self):
        return 'geocoder_internal'

    @property
    def is_high_resolution(self):
        return False

    @property
    def cost_per_hit(self):
        return 0

    @property
    def geocoding_quota(self):
        return None

    @property
    def log_path(self):
        return self._log_path


class GeocoderConfig(ServiceConfig):

    GEOCODER_CONFIG_KEYS = ['google_maps_client_id', 'google_maps_api_key',
                            'geocoding_quota', 'soft_geocoding_limit',
                            'geocoder_type', 'period_end_date',
                            'heremaps_geocoder_app_id', 'heremaps_geocoder_app_code',
                            'mapzen_geocoder_api_key', 'username', 'orgname']
    NOKIA_GEOCODER_REDIS_MANDATORY_KEYS = ['geocoding_quota', 'soft_geocoding_limit']
    NOKIA_GEOCODER = 'heremaps'
    NOKIA_GEOCODER_APP_ID_KEY = 'heremaps_geocoder_app_id'
    NOKIA_GEOCODER_APP_CODE_KEY = 'heremaps_geocoder_app_code'
    GOOGLE_GEOCODER = 'google'
    GOOGLE_GEOCODER_API_KEY = 'google_maps_api_key'
    GOOGLE_GEOCODER_CLIENT_ID = 'google_maps_client_id'
    MAPZEN_GEOCODER = 'mapzen'
    MAPZEN_GEOCODER_API_KEY = 'mapzen_geocoder_api_key'
    GEOCODER_TYPE = 'geocoder_type'
    QUOTA_KEY = 'geocoding_quota'
    SOFT_LIMIT_KEY = 'soft_geocoding_limit'
    USERNAME_KEY = 'username'
    ORGNAME_KEY = 'orgname'
    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_connection, db_conn, username, orgname=None):
        super(GeocoderConfig, self).__init__(redis_connection, db_conn,
                                             username, orgname)
        filtered_config = {key: self._redis_config[key] for key in self.GEOCODER_CONFIG_KEYS if key in self._redis_config.keys()}
        self.__parse_config(filtered_config, self._db_config)
        self.__check_config(filtered_config)

    def __get_user_config(self, username, orgname):
        user_config = self._redis_connection.hgetall(
            "rails:users:{0}".format(username))
        if not user_config:
            raise ConfigException("""There is no user config available. Please check your configuration.'""")
        else:
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
            if not set(self.NOKIA_GEOCODER_REDIS_MANDATORY_KEYS).issubset(set(filtered_config.keys())) or \
            not self.heremaps_app_id or not self.heremaps_app_code:
                raise ConfigException("""Some mandatory parameter/s for Nokia geocoder are missing. Check it please""")
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
            if self.GOOGLE_GEOCODER_API_KEY not in filtered_config.keys():
                raise ConfigException("""Google geocoder need the mandatory parameter 'google_maps_private_key'""")
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.MAPZEN_GEOCODER:
            if not self.mapzen_api_key:
                raise ConfigException("""Mapzen config is not setted up""")

        return True

    def __parse_config(self, filtered_config, db_config):
        self._geocoder_type = filtered_config[self.GEOCODER_TYPE].lower()
        self._geocoding_quota = float(filtered_config[self.QUOTA_KEY])
        self._period_end_date = date_parse(filtered_config[self.PERIOD_END_DATE])
        self._log_path = db_config.geocoder_log_path
        if filtered_config[self.SOFT_LIMIT_KEY].lower() == 'true':
            self._soft_geocoding_limit = True
        else:
            self._soft_geocoding_limit = False
        if filtered_config[self.GEOCODER_TYPE].lower() == self.NOKIA_GEOCODER:
            self._heremaps_app_id = db_config.heremaps_geocoder_app_id
            self._heremaps_app_code = db_config.heremaps_geocoder_app_code
            self._cost_per_hit = db_config.heremaps_geocoder_cost_per_hit
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.GOOGLE_GEOCODER:
            self._google_maps_api_key = filtered_config[self.GOOGLE_GEOCODER_API_KEY]
            self._google_maps_client_id = filtered_config[self.GOOGLE_GEOCODER_CLIENT_ID]
            self._cost_per_hit = 0
        elif filtered_config[self.GEOCODER_TYPE].lower() == self.MAPZEN_GEOCODER:
            self._mapzen_api_key = db_config.mapzen_geocoder_api_key
            self._geocoding_quota = db_config.mapzen_geocoder_monthly_quota
            self._cost_per_hit = 0

    @property
    def service_type(self):
        if self._geocoder_type == self.GOOGLE_GEOCODER:
            return 'geocoder_google'
        elif self._geocoder_type == self.MAPZEN_GEOCODER:
            return 'geocoder_mapzen'
        else:
            return 'geocoder_here'

    @property
    def heremaps_geocoder(self):
        return self._geocoder_type == self.NOKIA_GEOCODER

    @property
    def google_geocoder(self):
        return self._geocoder_type == self.GOOGLE_GEOCODER

    @property
    def mapzen_geocoder(self):
        return self._geocoder_type == self.MAPZEN_GEOCODER

    @property
    def google_client_id(self):
        return self._google_maps_client_id

    @property
    def google_api_key(self):
        return self._google_maps_api_key

    @property
    def geocoding_quota(self):
        if self.google_geocoder:
            return None
        else:
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
    def mapzen_api_key(self):
        return self._mapzen_api_key

    @property
    def is_high_resolution(self):
        return True

    @property
    def cost_per_hit(self):
        return self._cost_per_hit

    @property
    def log_path(self):
        return self._log_path


class ServicesDBConfig:

    def __init__(self, db_conn):
        self._db_conn = db_conn
        return self._build()

    def _build(self):
        self._get_here_config()
        self._get_mapzen_config()
        self._get_logger_config()
        self._get_data_observatory_config()

    def _get_here_config(self):
        heremaps_conf_json = self._get_conf('heremaps_conf')
        if not heremaps_conf_json:
            raise ConfigException('Here maps configuration missing')
        else:
            heremaps_conf = json.loads(heremaps_conf_json)
            self._heremaps_geocoder_app_id = heremaps_conf['geocoder']['app_id']
            self._heremaps_geocoder_app_code = heremaps_conf['geocoder']['app_code']
            self._heremaps_geocoder_cost_per_hit = heremaps_conf['geocoder'][
                'geocoder_cost_per_hit']
            self._heremaps_isolines_app_id = heremaps_conf['isolines']['app_id']
            self._heremaps_isolines_app_code = heremaps_conf['isolines']['app_code']

    def _get_mapzen_config(self):
        mapzen_conf_json = self._get_conf('mapzen_conf')
        if not mapzen_conf_json:
            raise ConfigException('Mapzen configuration missing')
        else:
            mapzen_conf = json.loads(mapzen_conf_json)
            self._mapzen_routing_api_key = mapzen_conf['routing']['api_key']
            self._mapzen_routing_quota = mapzen_conf['routing']['monthly_quota']
            self._mapzen_geocoder_api_key = mapzen_conf['geocoder']['api_key']
            self._mapzen_geocoder_quota = mapzen_conf['geocoder']['monthly_quota']

    def _get_data_observatory_config(self):
        do_conf_json = self._get_conf('data_observatory_conf')
        if not do_conf_json:
            raise ConfigException('Data Observatory configuration missing')
        else:
            do_conf = json.loads(do_conf_json)
            self._data_observatory_monthly_quota = do_conf['monthly_quota']

    def _get_logger_config(self):
        logger_conf_json = self._get_conf('logger_conf')
        if not logger_conf_json:
            raise ConfigException('Logger configuration missing')
        else:
            logger_conf = json.loads(logger_conf_json)
            self._geocoder_log_path = logger_conf['geocoder_log_path']

    def _get_conf(self, key):
        try:
            sql = "SELECT cartodb.CDB_Conf_GetConf('{0}') as conf".format(key)
            conf = self._db_conn.execute(sql, 1)
            return conf[0]['conf']
        except Exception as e:
            raise ConfigException("Malformed config for {0}: {1}".format(key, e))

    @property
    def heremaps_isolines_app_id(self):
        return self._heremaps_isolines_app_id

    @property
    def heremaps_isolines_app_code(self):
        return self._heremaps_isolines_app_code

    @property
    def heremaps_geocoder_app_id(self):
        return self._heremaps_geocoder_app_id

    @property
    def heremaps_geocoder_app_code(self):
        return self._heremaps_geocoder_app_code

    @property
    def heremaps_geocoder_cost_per_hit(self):
        return self._heremaps_geocoder_cost_per_hit

    @property
    def mapzen_routing_api_key(self):
        return self._mapzen_routing_api_key

    @property
    def mapzen_routing_monthly_quota(self):
        return self._mapzen_routing_quota

    @property
    def mapzen_geocoder_api_key(self):
        return self._mapzen_geocoder_api_key

    @property
    def mapzen_geocoder_monthly_quota(self):
        return self._mapzen_geocoder_quota

    @property
    def geocoder_log_path(self):
        return self._geocoder_log_path

    @property
    def data_observatory_monthly_quota(self):
        return self._data_observatory_monthly_quota


class ServicesRedisConfig:

    GOOGLE_GEOCODER_API_KEY = 'google_maps_api_key'
    GOOGLE_GEOCODER_CLIENT_ID = 'google_maps_client_id'
    QUOTA_KEY = 'geocoding_quota'
    ISOLINES_QUOTA_KEY = 'here_isolines_quota'
    PERIOD_END_DATE = 'period_end_date'

    def __init__(self, redis_conn):
        self._redis_connection = redis_conn

    def build(self, username, password):
        return self.__get_user_config(username, password)

    def __get_user_config(self, username, orgname):
        user_config = self._redis_connection.hgetall(
            "rails:users:{0}".format(username))
        if not user_config:
            raise ConfigException("""There is no user config available. Please check your configuration.'""")
        else:
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
            user_config[self.ISOLINES_QUOTA_KEY] = org_config[self.ISOLINES_QUOTA_KEY]
            user_config[self.PERIOD_END_DATE] = org_config[self.PERIOD_END_DATE]
            user_config[self.GOOGLE_GEOCODER_CLIENT_ID] = org_config[self.GOOGLE_GEOCODER_CLIENT_ID]
            user_config[self.GOOGLE_GEOCODER_API_KEY] = org_config[self.GOOGLE_GEOCODER_API_KEY]

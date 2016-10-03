class ServerEnvironment(object):

    DEVELOPMENT = 'development'
    STAGING = 'staging'
    PRODUCTION = 'production'
    ONPREMISE = 'onpremise'

    VALID_ENVIRONMENTS = [
        DEVELOPMENT,
        STAGING,
        PRODUCTION,
        ONPREMISE
    ]

    def __init__(self, environment_str):
        assert environment_str in self.VALID_ENVIRONMENTS
        self._environment_str = environment_str

    def __str__(self):
        return self._environment_str

    @property
    def is_onpremise(self):
        return self._environment_str == self.ONPREMISE


class ServerEnvironmentBuilder(object):

    DEFAULT_ENVIRONMENT = ServerEnvironment.DEVELOPMENT

    def __init__(self, server_config_storage):
        self._server_config_storage = server_config_storage

    def get(self):
        server_config = self._server_config_storage.get('server_conf')

        if not server_config or 'environment' not in server_config:
            environment_str = self.DEFAULT_ENVIRONMENT
        else:
            environment_str = server_config['environment']

        return ServerEnvironment(environment_str)

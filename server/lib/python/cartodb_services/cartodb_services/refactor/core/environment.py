class Environment:
    def __init__(self, server_config_storage):
        self._server_config_storage = server_config_storage

    def get(self):
        server_config = self._server_config_storage.get('server_conf')

        if not server_config or 'environment' not in server_config:
            environment = 'development'
        else:
            environment = server_config['environment']

        return environment

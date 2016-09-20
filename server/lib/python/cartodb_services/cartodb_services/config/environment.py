from server_config import ServerConfigFactory

class Environment:
    def __init__(self):
        self._server_config = ServerConfigFactory.get()

    def get(self):
        server_config = self._server_config.get('server_conf')

        if not server_config or 'environment' not in server_config:
            environment = 'development'
        else:
            environment = server_config['environment']

        return environment

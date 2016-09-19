from db_config import DBConfig
import json

class Environment:
    def __init__(self):
        self._db_config = DBConfig()

    def get(self):
        server_config_json = self._db_config.get('server_conf')

        if not server_config_json:
            environment = 'development'
        else:
            server_config_json = json.loads(server_config_json)
            if 'environment' in server_config_json:
                environment = server_config_json['environment']
            else:
                environment = 'development'

        return environment

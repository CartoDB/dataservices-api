from interfaces import ConfigStorageInterface

class InMemoryConfigStorage(ConfigStorageInterface):

    def __init__(self, config_hash={}):
        self._config_hash = config_hash

    def get(self, key):
        try:
            return self._config_hash[key]
        except KeyError:
            return None

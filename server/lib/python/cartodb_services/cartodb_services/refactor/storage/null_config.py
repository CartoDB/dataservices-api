from interfaces import ConfigStorageInterface

class NullConfigStorage(ConfigStorageInterface):

    def get(self, key):
        return None

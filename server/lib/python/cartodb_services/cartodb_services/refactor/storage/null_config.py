from ..core.interfaces import ConfigBackendInterface

class NullConfigStorage(ConfigBackendInterface):

    def get(self, key, default=None):
        return default

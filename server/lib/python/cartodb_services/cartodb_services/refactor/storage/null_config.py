from ..core.interfaces import ConfigBackendInterface

class NullConfigStorage(ConfigBackendInterface):

    def get(self, key):
        return None

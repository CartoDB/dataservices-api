import abc

class ConfigBackendInterface(object):
    """This is an interface that all config backends must abide to"""

    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def get(self, key):
        """Return a value based on the key supplied from some storage"""
        pass

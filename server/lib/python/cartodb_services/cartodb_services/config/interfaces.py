import abc

class ConfigStorageInterface(object):
    """This is an interface that all config storages must abide to"""

    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def get(self, key):
        """Return a value based on the key supplied from some storage"""
        pass

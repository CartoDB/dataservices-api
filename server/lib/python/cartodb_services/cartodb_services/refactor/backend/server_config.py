from cartodb_services.refactor.storage.server_config import InDbServerConfigStorage


class ServerConfigBackendFactory(object):
    """
    This class creates a backend to retrieve server configurations (implementing the ConfigBackendInterface).

    At this moment it will always return an InDbServerConfigStorage, but nothing prevents from changing the
    implementation. To something that reads from a file, memory or whatever. It is mostly there to keep
    the layers separated.
    """
    def get(self):
        return InDbServerConfigStorage()

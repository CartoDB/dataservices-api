class Configs(object):
    """Just a container for the different configurations, to be used by client services"""

    def __init__(self, server_config, user_config, org_config):
        self._server_config = server_config
        self._user_config = user_config
        self._org_config = org_config

    @property
    def server_config(self):
        return self._server_config

    @property
    def user_config(self):
        return self._user_config

    @property
    def org_config(self):
        return self._org_config

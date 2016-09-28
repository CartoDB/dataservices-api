import cartodb_services

class Request(object):
    """
    A request represents a unique call to an entry point.
    It can be a container of useful information.
    """

    def __init__(self, id, user, configs, function_name):
        self._id = id
        self._user = user
        self._configs = configs
        self._function_name = function_name

    @property
    def id(self):
        return self._id

    @property
    def user(self):
        return self._user

    @property
    def configs(self):
        return self._configs

    @property
    def function_name(self):
        return self._function_name


class TxId(object):

    @classmethod
    def get(cls):
        """Return the current transaction id"""
        ret = cartodb_services.plpy.execute('SELECT txid_current();')
        txid = ret[0]['txid_current']
        return txid


class RequestFactory(object):

    _requests = {}

    def __init__(self, id_generator=TxId):
        self._id_generator = id_generator

    def create(self, user, configs, function_name):
        id = self._id_generator.get()
        if id not in self._requests:
            req = Request(id, user, configs, function_name)
            self._requests[id] = req
        else:
            req = self._requests[id]
        return req

    def get(self, id):
        return self._requests[id]

    def current(self):
        id = self._id_generator.get()
        return self._requests[id]


class User(object):

    def __init__(self, username, orgname = None):
        self.__username = username
        self.__orgname = orgname

    @property
    def username(self):
        return self.__username

    @property
    def orgname(self):
        return self.__orgname

    @property
    def is_org_user(self):
        return self.__orgname is not None

    def __eq__(self, other):
        # NOTE: usernames are unique in the system
        eq = (self.__username == other.__username)
        if eq:
            assert self.__orgname == other.__orgname, 'Found two users with same name and different orgs!'
        return eq

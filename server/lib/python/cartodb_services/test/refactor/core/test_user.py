from unittest import TestCase
from cartodb_services.refactor.core.user import User
from nose.tools import assert_raises, raises

class TestUser(TestCase):

    def test_can_retrieve_properties(self):
        u = User('pepito', 'acme')
        assert u.username == 'pepito'
        assert u.orgname == 'acme'

    @raises(AttributeError)
    def test_cannot_modify_properties(self):
        u = User('pepito')
        u.username = 'juanito'

    def test_is_org_user_returns_true_for_org_users(self):
        u = User('pepito', 'acme')
        assert u.is_org_user == True

    def test_is_org_user_returns_false_for_non_org_users(self):
        u = User('pepito')
        assert u.is_org_user == False

    def test_different_users_are_not_equal(self):
        u1 = User('pepito')
        u2 = User('juanito')
        assert u1 != u2

    def test_same_user_are_equal(self):
        u1 = User('pepito')
        u2 = User('pepito')
        assert u1 == u2

        o1 = User('juanito', 'acme')
        o2 = User('juanito', 'acme')
        assert o1 == o2

    @raises(AssertionError)
    def test_raises_exception_if_same_user_is_in_two_orgs(self):
        u1 = User('juanito', 'acme')
        u2 = User('juanito', 'some_other_org')
        u1 == u2

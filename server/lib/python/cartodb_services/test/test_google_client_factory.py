#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps
import unittest
import base64

from cartodb_services.google.client_factory import GoogleMapsClientFactory
from cartodb_services.google.exceptions import InvalidGoogleCredentials

class GoogleMapsClientFactoryTestCase(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        # reset client cache
        GoogleMapsClientFactory.clients = {}

    def test_consecutive_calls_with_same_params_return_same_client(self):
        id = 'any_id'
        key = base64.b64encode('any_key')
        client1 = GoogleMapsClientFactory.get(id, key)
        client2 = GoogleMapsClientFactory.get(id, key)
        self.assertEqual(client1, client2)

    def test_consecutive_calls_with_different_key_return_different_clients(self):
        """
        This requirement is important for security reasons as well as not to
        cache a wrong key accidentally.
        """
        id = 'any_id'
        key1 = base64.b64encode('any_key')
        key2 = base64.b64encode('another_key')
        client1 = GoogleMapsClientFactory.get(id, key1)
        client2 = GoogleMapsClientFactory.get(id, key2)
        self.assertNotEqual(client1, client2)

    def test_consecutive_calls_with_different_ids_return_different_clients(self):
        """
        This requirement is important for security reasons as well as not to
        cache a wrong key accidentally.
        """
        id1 = 'any_id'
        id2 = 'another_id'
        key = base64.b64encode('any_key')
        client1 = GoogleMapsClientFactory.get(id1, key)
        client2 = GoogleMapsClientFactory.get(id2, key)
        self.assertNotEqual(client1, client2)

    def test_invalid_credentials(self):
        with self.assertRaises(InvalidGoogleCredentials):
            GoogleMapsClientFactory.get('dummy_client_id', 'lalala')

    def test_credentials_with_dashes_can_be_valid(self):
        client = GoogleMapsClientFactory.get('yet_another_dummy_client_id', 'Ola-k-ase---')
        self.assertIsInstance(client, googlemaps.Client)

    def test_credentials_with_underscores_can_be_valid(self):
        client = GoogleMapsClientFactory.get('yet_another_dummy_client_id', 'Ola_k_ase___')
        self.assertIsInstance(client, googlemaps.Client)

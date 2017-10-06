#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps
import base64
from exceptions import InvalidGoogleCredentials

class GoogleMapsClientFactory():
    clients = {}

    @classmethod
    def get(cls, client_id, client_secret):
        client = cls.clients.get(client_id)
        if not client:
            cls.assert_valid_crendentials(client_secret)
            client = googlemaps.Client(
                client_id=client_id,
                client_secret=client_secret)
            cls.clients[client_id] = client
        return client

    @classmethod
    def assert_valid_crendentials(cls, client_secret):
        if not cls.valid_credentials(client_secret):
            raise InvalidGoogleCredentials

    @staticmethod
    def valid_credentials(client_secret):
        try:
            # Only fails if the string dont have a correct padding for b64
            # but this way we could provide a more clear error than
            # TypeError: Incorrect padding
            b64_secret = client_secret.replace('-', '+').replace('_', '/')
            base64.b64decode(b64_secret)
            return True
        except TypeError:
            return False

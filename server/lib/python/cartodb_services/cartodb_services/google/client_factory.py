#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps
import base64
from cartodb_services.google.exceptions import InvalidGoogleCredentials


class GoogleMapsClientFactory():
    clients = {}

    @classmethod
    def get(cls, client_id, client_secret, channel=None):
        cache_key = "{}:{}:{}".format(client_id, client_secret, channel)
        client = cls.clients.get(cache_key)
        if not client:
            if client_id:
                cls.assert_valid_crendentials(client_secret)
                client = googlemaps.Client(
                    client_id=client_id,
                    client_secret=client_secret,
                    channel=channel)
            else:
                client = googlemaps.Client(key=client_secret)
            cls.clients[cache_key] = client
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

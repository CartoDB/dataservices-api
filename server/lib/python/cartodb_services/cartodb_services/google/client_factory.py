#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps

class GoogleMapsClientFactory():
    clients = {}

    @classmethod
    def get(cls, client_id, client_secret):
        client = cls.clients.get(client_id)
        if not client:
            client = googlemaps.Client(
                client_id=client_id,
                client_secret=client_secret)
            cls.clients[client_id] = client
        return client

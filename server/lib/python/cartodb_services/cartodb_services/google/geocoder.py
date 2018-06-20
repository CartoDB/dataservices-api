#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import googlemaps
from urlparse import parse_qs

from exceptions import MalformedResult
from cartodb_services.google.exceptions import InvalidGoogleCredentials
from client_factory import GoogleMapsClientFactory

from multiprocessing import Pool, TimeoutError

import json

import time, random

def async_geocoder(geocoder, address):
    # time.sleep(.3 + random.random())
    # return [{ 'geometry': { 'location': { 'lng': 1, 'lat': 2 } } }]

    results = geocoder.geocode(address=address)
    return results if results else []

class GoogleMapsGeocoder:
    """A Google Maps Geocoder wrapper for python"""
    PARALLEL_PROCESSES = 13

    def __init__(self, client_id, client_secret, logger):
        if client_id is None:
            raise InvalidGoogleCredentials
        self.client_id, self.channel = self.parse_client_id(client_id)
        self.client_secret = client_secret
        self.geocoder = GoogleMapsClientFactory.get(self.client_id, self.client_secret, self.channel)
        self._logger = logger

    def geocode(self, searchtext, city=None, state=None,
                country=None):
        try:
            opt_params = self._build_optional_parameters(city, state, country)
            results = self.geocoder.geocode(address=searchtext,
                                            components=opt_params)
            if results:
                return self._extract_lng_lat_from_result(results[0])
            else:
                return []
        except KeyError:
            raise MalformedResult()

    def bulk_geocode(self, searchtext):
        try:
            decoded_searchtext = json.loads(searchtext)
        except Exception as e:
            self._logger.error('General error', exception=e)
            raise e

        bulk_results = {}
        pool = Pool(processes=self.PARALLEL_PROCESSES)
        for search in decoded_searchtext:
            search_id, address = [search[k] for k in ['id', 'address']]
            if address:
                result = pool.apply_async(async_geocoder,
                                          (self.geocoder, address))
            else:
                result = []
            bulk_results[search_id] = result
        pool.close()
        pool.join()

        try:
            results = []
            for search_id, bulk_result in bulk_results.items():
                try:
                    result = bulk_result.get()
                except Exception as e:
                    self._logger.error('Error at Google async_geocoder', e)
                    result = []

                lng_lat = self._extract_lng_lat_from_result(result[0]) if result else []
                results.append([search_id, lng_lat, []])
            return results
        except KeyError as e:
            self._logger.error('KeyError error', exception=e)
            raise MalformedResult()
        except Exception as e:
            self._logger.error('General error', exception=e)
            raise e

    def _extract_lng_lat_from_result(self, result):
        location = result['geometry']['location']
        longitude = location['lng']
        latitude = location['lat']
        return [longitude, latitude]

    def _build_optional_parameters(self, city=None, state=None,
                                   country=None):
        optional_params = {}
        if city:
            optional_params['locality'] = city
        if state:
            optional_params['administrative_area'] = state
        if country:
            optional_params['country'] = country
        return optional_params

    def parse_client_id(self, client_id):
        arguments = parse_qs(client_id)
        client = arguments['client'][0] if arguments.has_key('client') else client_id
        channel = arguments['channel'][0] if arguments.has_key('channel') else None
        return client, channel

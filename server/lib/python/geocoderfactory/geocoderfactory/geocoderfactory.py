#!/usr/local/bin/python
# -*- coding: utf-8 -*-

from googlemapswrapper import googlemapsgeocoder
from heremaps import heremapsgeocoder

from geocoderfactoryexceptions import BadGeocoderCreation

class Factory(object):
    app_id = ''
    app_secret = ''

    def __init__(self, app_id, app_secret):
      self.app_id = app_id
      self.app_secret = app_secret

    def factory(self, type):
        if type == 'gme': return googlemapsgeocoder.Geocoder(self.app_id, self.app_secret)
        elif type == 'hires': return heremapsgeocoder.Geocoder(self.app_id, self.app_secret)
        else: raise BadGeocoderCreation(type)

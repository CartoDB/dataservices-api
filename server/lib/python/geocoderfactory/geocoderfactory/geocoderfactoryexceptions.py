#!/usr/local/bin/python
# -*- coding: utf-8 -*-

class BadGeocoderCreation(Exception):
    def __init__(self, type):
        self.type = type
    def __str__(self):
        return repr('Bad Geocoder creation. type: ' + self.type)


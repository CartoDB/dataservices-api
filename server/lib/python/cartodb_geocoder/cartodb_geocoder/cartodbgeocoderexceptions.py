#!/usr/local/bin/python
# -*- coding: utf-8 -*-

class BadAuthDictionary(Exception):
    def __str__(self):
        return repr('Malformed auth dictionary.')

class UnknownProvider(Exception):
    def __init__(self, value):
      self.value = value
    def __str__(self):
        return repr("Provider '{}' is unkown.".format(self.value))

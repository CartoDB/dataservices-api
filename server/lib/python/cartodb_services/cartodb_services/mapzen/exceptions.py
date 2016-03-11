#!/usr/local/bin/python
# -*- coding: utf-8 -*-
import json


class WrongParams(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr('Wrong parameters passed: ' + json.dumps(self.value))


class MalformedResult(Exception):
    def __str__(self):
            return repr('Result structure is malformed')


class TimeoutException(Exception):
    def __str__(self):
            return repr('Timeout requesting to mapzen server')

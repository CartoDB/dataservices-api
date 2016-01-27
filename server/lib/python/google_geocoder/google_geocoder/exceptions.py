#!/usr/local/bin/python
# -*- coding: utf-8 -*-


class MalformedResult(Exception):
    def __str__(self):
        return repr('Malformed result. The API might have changed.')

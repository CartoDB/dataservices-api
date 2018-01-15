import json


class TimeoutException(Exception):
    def __str__(self):
        return repr('Timeout requesting to server')


class ServiceException(Exception):
    def __init__(self, message, response):
        self.message = message
        self.response = response

    def response(self):
        return self.response

    def __str__(self):
        return self.message


class WrongParams(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr('Wrong parameters passed: ' + json.dumps(self.value))


class MalformedResult(Exception):
    def __str__(self):
            return repr('Result structure is malformed')

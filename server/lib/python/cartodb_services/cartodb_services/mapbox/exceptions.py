'''
Exceptions for the Mapbox services Python wrapper.
'''


class ServiceException(Exception):
    '''
    Exception to be raised if any Service problem is found.
    '''

    def __init__(self, code, message):
        self.code = code
        self.message = message

    def __str__(self):
        return repr('ServiceException ({code}): {message}'.format(
            code=self.code,
            message=self.message))

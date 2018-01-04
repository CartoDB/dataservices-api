class TimeoutException(Exception):
    def __str__(self):
        return repr('Timeout requesting to server')

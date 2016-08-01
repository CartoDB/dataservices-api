import plpy
import rollbar
import sys
# Monkey path because plpython sys module doesn't have argv and rollbar
# package use it
sys.__dict__['argv'] = []


class Logger:

    def __init__(self, config):
        self._config = config
        # We need to set the handler blocking (synchronous) because
        # spawn a thread from plpython interpreter don't work
        rollbar.init(self._config.rollbar_api_key,
                     self._config.environment, handler='blocking')

    def debug(self, text, exception=None, data={}):
        self._send_to_rollbar('debug', text, exception, data)
        plpy.debug(text)

    def info(self, text, exception=None, data={}):
        self._send_to_rollbar('info', text, exception, data)
        plpy.info(text)

    def warning(self, text, exception=None, data={}):
        self._send_to_rollbar('warning', text, exception, data)
        plpy.warning(text)

    def error(self, text, exception=None, data={}):
        self._send_to_rollbar('error', text, exception, data)
        plpy.error(text)

    def _send_to_rollbar(self, level, text, exception, data):
        if self._rollbar_activated():
            try:
                if exception:
                    rollbar.report_exc_info(exception, extra_data=data,
                                            level=level)
                else:
                    rollbar.report_message(text, level, extra_data=data)
            except Exception as e:
                plpy.warning('Error sending message/exception to rollbar: {0}'.
                             format(e))

    def _rollbar_activated(self):
        return True if self._config.rollbar_api_key else False

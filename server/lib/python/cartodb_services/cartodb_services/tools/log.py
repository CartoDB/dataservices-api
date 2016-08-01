import plpy
import rollbar
import logging
import traceback
import sys
# Monkey path because plpython sys module doesn't have argv and rollbar
# package use it
sys.__dict__['argv'] = []


class Logger:

    LEVELS = {'debug': 1, 'info': 2, 'warning': 3, 'error': 4}

    def __init__(self, config):
        self._config = config
        self._min_level = self.LEVELS[self._config.min_log_level]
        # We need to set the handler blocking (synchronous) because
        # spawn a thread from plpython interpreter don't work
        if self._rollbar_activated():
            rollbar.init(self._config.rollbar_api_key,
                        self._config.environment, handler='blocking')
        if self._log_file_activated():
            self._setup_log_file_config(self._config.log_file_path)

    def debug(self, text, exception=None, data={}):
        if not self._check_min_level('debug'):
            return
        self._send_to_rollbar('debug', text, exception, data)
        self._send_to_log_file('debug', text, exception, data)
        plpy.debug(text)

    def info(self, text, exception=None, data={}):
        if not self._check_min_level('info'):
            return
        self._send_to_rollbar('info', text, exception, data)
        self._send_to_log_file('info', text, exception, data)
        plpy.info(text)

    def warning(self, text, exception=None, data={}):
        if not self._check_min_level('warning'):
            return
        self._send_to_rollbar('warning', text, exception, data)
        self._send_to_log_file('warning', text, exception, data)
        plpy.warning(text)

    def error(self, text, exception=None, data={}):
        if not self._check_min_level('error'):
            return
        self._send_to_rollbar('error', text, exception, data)
        self._send_to_log_file('error', text, exception, data)
        # Plpy.error and fatal raises exceptions and we only want to log an
        # error, exceptions should be raise explicitly
        plpy.warning(text)

    def _check_min_level(self, level):
        return True if self.LEVELS[level] >= self._min_level else False

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

    def _send_to_log_file(self, level, text, exception, data):
        extra_data = self._parse_log_extra_data(exception, data)
        if level == 'debug':
            logging.debug(text, extra=extra_data)
        elif level == 'info':
            logging.info(text, extra=extra_data)
        elif level == 'warning':
            logging.warning(text, extra=extra_data)
        elif level == 'error':
            logging.error(text, extra=extra_data)

    def _parse_log_extra_data(self, exception, data):
        if exception:
            type_, value_, traceback_ = exception
            exception_traceback = traceback.format_tb(traceback_)
            extra_data = {"exception_type": type_, "exception_message": value_,
                          "exception_traceback": exception_traceback,
                          "log_data": data}
        else:
            extra_data = {"exception_type": '', "exception_message": '',
                          "exception_traceback": ''}

        if data:
            extra_data['data'] = data
        else:
            extra_data['data'] = ''

        return extra_data

    def _setup_log_file_config(self, log_file_path):
        format_str = "%(asctime)s %(name)-12s %(levelname)-8s %(message)s %(data)s %(exception_type)s %(exception_message)s %(exception_traceback)s"
        logging.basicConfig(filename=log_file_path, format=format_str, level=self._config.min_log_level.upper())

    def _rollbar_activated(self):
        return True if self._config.rollbar_api_key else False

    def _log_file_activated(self):
        return True if self._config.log_file_path else False

import re


class MockCursor:
    def __init__(self, data):
        self.cursor_pos = 0
        self.data = data

    def fetch(self, batch_size):
        batch = self.data[self.cursor_pos: self.cursor_pos + batch_size]
        self.cursor_pos += batch_size
        return batch


class MockPlPy:
    def __init__(self):
        self._reset()

    def _reset(self, log_executed_queries=False):
        self.infos = []
        self.notices = []
        self.debugs = []
        self.logs = []
        self.warnings = []
        self.errors = []
        self.fatals = []
        self.executes = []
        self.results = []
        self.prepares = []
        self.results = {}
        self._log_executed_queries = log_executed_queries
        self._logged_queries = []

    def _define_result(self, query, result):
        pattern = re.compile(query, re.IGNORECASE | re.MULTILINE)
        self.results[pattern] = result

    def _executed_queries(self):
        if self._log_executed_queries:
            return self._logged_queries
        else:
            raise Exception('Executed queries logging is not active')

    def _has_executed_query(self, query):
        pattern = re.compile(re.escape(query))
        for executed_query in self._executed_queries():
            if pattern.search(executed_query):
                return True
        return False

    def _start_logging_executed_queries(self):
        self._logged_queries = []
        self._log_executed_queries = True

    def notice(self, msg):
        self.notices.append(msg)

    def debug(self, msg):
        self.notices.append(msg)

    def info(self, msg):
        self.infos.append(msg)

    def cursor(self, query):
        data = self.execute(query)
        return MockCursor(data)

    def execute(self, query, rows=1):
        if self._log_executed_queries:
            self._logged_queries.append(query)
        for pattern, result in self.results.iteritems():
            if pattern.search(query):
                return result
        return []

    def quote_nullable(self, value):
        if value is None:
            return 'NULL'
        else:
            return "'{0}'".format(value)

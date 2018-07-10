#!/usr/local/bin/python
# -*- coding: utf-8 -*-


import requests, time, zipfile, io, csv, cStringIO
import xml.etree.ElementTree as ET
from collections import namedtuple
from requests.adapters import HTTPAdapter
from cartodb_services import StreetPointBulkGeocoder
from cartodb_services.here import HereMapsGeocoder
from cartodb_services.metrics import Traceable
from cartodb_services.tools.exceptions import ServiceException


HereJobStatus = namedtuple('HereJobStatus', 'total_count processed_count status')

class HereMapsBulkGeocoder(HereMapsGeocoder, StreetPointBulkGeocoder):
    MAX_BATCH_SIZE = 1000000  # From the docs
    MIN_BATCHED_SEARCH = 1000  # Under this, serial will be used
    BATCH_URL = 'https://batch.geocoder.cit.api.here.com/6.2/jobs'
    # https://developer.here.com/documentation/batch-geocoder/topics/read-batch-request-output.html
    META_COLS = ['relevance', 'matchType', 'matchCode', 'matchLevel', 'matchQualityStreet']
    MAX_STALLED_RETRIES = 100
    BATCH_RETRY_SLEEP_S = 5
    JOB_FINAL_STATES = ['completed', 'cancelled', 'deleted', 'failed']

    def __init__(self, app_id, app_code, logger, service_params=None, maxresults=HereMapsGeocoder.DEFAULT_MAXRESULTS):
        HereMapsGeocoder.__init__(self, app_id, app_code, logger, service_params, maxresults)
        self.session = requests.Session()
        self.session.mount(self.BATCH_URL,
                           HTTPAdapter(max_retries=self.max_retries))
        self.credentials_params = {
            'app_id': self.app_id,
            'app_code': self.app_code,
        }

    def _should_use_batch(self, searches):
        return len(searches) >= self.MIN_BATCHED_SEARCH

    def _serial_geocode(self, searches):
        results = []
        for search in searches:
            (search_id, address, city, state, country) = search
            coordinates = self.geocode(searchtext=address, city=city, state=state, country=country)
            results.append((search_id, coordinates, []))
        return results

    def _batch_geocode(self, searches):
        request_id = self._send_batch(self._searches_to_csv(searches))
        self._logger.debug('--> Sent batch {}'.format(request_id))

        last_processed = 0
        stalled_retries = 0
        # https://developer.here.com/documentation/batch-geocoder/topics/job-status.html
        while True:
            job_info = self._job_status(request_id)
            if job_info.processed_count == last_processed:
                self._logger.debug('--> no progress ({})'.format(last_processed))
                stalled_retries += 1
                if stalled_retries > self.MAX_STALLED_RETRIES:
                    raise Exception('Too many retries for job {}'.format(request_id))
            else:
                self._logger.debug('--> progress ({} != {})'.format(job_info.processed_count, last_processed))
                stalled_retries = 0
                last_processed = job_info.processed_count

            self._logger.debug('--> Job poll check ({}): {}'.format(
                stalled_retries, job_info))
            if job_info.status in self.JOB_FINAL_STATES:
                break
            else:
                time.sleep(self.BATCH_RETRY_SLEEP_S)

        self._logger.debug('--> Job complete: {}'.format(job_info))

        results = self._download_results(request_id)
        self._logger.debug('--> Results: {} rows; {}'.format(len(results), results))

        return results

    def _searches_to_csv(self, searches):
        queue = cStringIO.StringIO()
        writer = csv.writer(queue, delimiter='|')
        writer.writerow(['recId', 'searchText', 'country'])

        for search in searches:
            fields = [search.address, search.city, search.state]
            search_text = ', '.join(filter(None, fields))
            row = [s.encode("utf-8") if s else ''
                   for s in [str(search.id), search_text, search.country]]
            writer.writerow(row)

        return queue.getvalue()

    def _send_batch(self, data):
        cols = 'displayLatitude,displayLongitude,' + ','.join(self.META_COLS)
        request_params = self.credentials_params.copy()
        request_params.update({
            'gen': 8,
            'action': 'run',
            # 'mailto': 'juanignaciosl@carto.com',
            'header': 'true',
            'inDelim': '|',
            'outDelim': '|',
            'outCols': cols,
            'outputcombined': 'true'
        })

        response = self.session.post(self.BATCH_URL, data=data,
                                     params=request_params,
                                     timeout=(self.connect_timeout, self.read_timeout))

        if response.status_code == 200:
            root = ET.fromstring(response.text)
            return root.find('./Response/MetaInfo/RequestId').text
        else:
            raise ServiceException("Error sending HERE batch", response)

    def _job_status(self, request_id):
        polling_params = self.credentials_params.copy()
        polling_params.update({'action': 'status'})
        polling_r = self.session.get("{}/{}".format(self.BATCH_URL, request_id),
                                params=polling_params,
                                timeout=(self.connect_timeout, self.read_timeout))
        polling_root = ET.fromstring(polling_r.text)
        return HereJobStatus(
            total_count=int(polling_root.find('./Response/TotalCount').text),
            processed_count=int(polling_root.find('./Response/ProcessedCount').text),
            status=polling_root.find('./Response/Status').text)

    def _download_results(self, job_id):
        result_r = self.session.get("{}/{}/result".format(self.BATCH_URL, job_id),
                                    params=self.credentials_params,
                                    timeout=(self.connect_timeout, self.read_timeout))
        root_zip = zipfile.ZipFile(io.BytesIO(result_r.content))

        results = []
        for name in root_zip.namelist():
            if name.endswith('_out.txt'):
                reader = csv.DictReader(root_zip.open(name), delimiter='|')
                for row in reader:
                    if row['SeqNumber'] == '1':  # First per requested data
                        results.append((row['recId'], [row['displayLongitude'], row['displayLatitude']]))

        return results


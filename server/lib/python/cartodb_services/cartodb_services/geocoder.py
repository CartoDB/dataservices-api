#!/usr/local/bin/python
# -*- coding: utf-8 -*-

from tools import QuotaExceededException, Logger
from collections import namedtuple
import json


PRECISION_PRECISE = 'precise'
PRECISION_INTERPOLATED = 'interpolated'

def geocoder_metadata(relevance, precision, match_types):
    return {
        'relevance': round(relevance, 2),
        'precision': precision,
        'match_types': match_types
    }


def geocoder_error_response(message):
    return [[], {'error': message}]


# Single empty result
EMPTY_RESPONSE = [[], {}]
# HTTP 429 and related
TOO_MANY_REQUESTS_ERROR_RESPONSE = geocoder_error_response('Rate limit exceeded')
# Full empty _batch_geocode response
EMPTY_BATCH_RESPONSE = []


def compose_address(street, city=None, state=None, country=None):
    return ', '.join(filter(None, [street, city, state, country]))


def run_street_point_geocoder(plpy, GD, geocoder, service_manager, username, orgname, searches_string):
    plpy.execute("SELECT cdb_dataservices_server._get_logger_config()")
    logger_config = GD["logger_config"]

    logger = Logger(logger_config)

    success_count, failed_count, empty_count = 0, 0, 0

    try:
        searches = json.loads(searches_string)
    except Exception as e:
        logger.error('Parsing searches', exception=e, data={'searches': searches_string})
        raise e

    try:
        service_manager.assert_within_limits(quota=False)
        geocode_results = geocoder.bulk_geocode(searches)
        results = []
        a_failed_one = None
        if not geocode_results == EMPTY_BATCH_RESPONSE:
            for result in geocode_results:
                metadata = result[2] if len(result) > 2 else {}

                if metadata.get('error', None):
                    results.append([result[0], None, json.dumps(metadata)])
                    a_failed_one = result
                    failed_count += 1
                elif result[1] and len(result[1]) == 2:
                    plan = plpy.prepare("SELECT ST_SetSRID(ST_MakePoint($1, $2), 4326) as the_geom; ", ["double precision", "double precision"])
                    point = plpy.execute(plan, result[1], 1)[0]
                    results.append([result[0], point['the_geom'], json.dumps(metadata)])
                    success_count += 1
                else:
                    results.append([result[0], None, json.dumps(metadata)])
                    empty_count += 1

        missing_count = len(searches) - success_count - failed_count - empty_count

        logger.debug("--> Success: {}; empty: {}; missing: {}, failed: {}".
                     format(success_count, empty_count, missing_count, failed_count))
        if a_failed_one:
            logger.warning("failed geocoding",
                           data={
                               "username": username,
                               "orgname": orgname,
                               "failed": str(a_failed_one),
                               "success_count": success_count,
                               "empty_count": empty_count,
                               "missing_count": missing_count,
                               "failed_count": failed_count
                           })
        service_manager.quota_service.increment_success_service_use(success_count)
        service_manager.quota_service.increment_empty_service_use(empty_count + missing_count)
        service_manager.quota_service.increment_failed_service_use(failed_count)

        return results
    except QuotaExceededException as qe:
        logger.debug('QuotaExceededException at run_street_point_geocoder', qe,
                     data={"username": username, "orgname": orgname})
        service_manager.quota_service.increment_failed_service_use(len(searches))
        return []
    except BaseException as e:
        import sys
        service_manager.quota_service.increment_failed_service_use(len(searches))
        service_manager.logger.error('Error trying to bulk geocode street point', sys.exc_info(), data={"username": username, "orgname": orgname})
        raise Exception('Error trying to bulk geocode street')
    finally:
        service_manager.quota_service.increment_total_service_use(len(searches))


StreetGeocoderSearch = namedtuple('StreetGeocoderSearch', 'id address city state country')


class StreetPointBulkGeocoder:
    """
    Classes extending StreetPointBulkGeocoder should implement:
        * _batch_geocode(street_geocoder_searches)
        * MAX_BATCH_SIZE

    If they want to provide an alternative serial (for small batches):
        * _should_use_batch(street_geocoder_searches)
        * _serial_geocode(street_geocoder_searches)
    """

    SEARCH_KEYS = ['id', 'address', 'city', 'state', 'country']

    def bulk_geocode(self, decoded_searches):
        """
        :param decoded_searches: JSON array
        :return: array of tuples with three elements:
            * id
            * latitude and longitude (array of two elements)
            * empty array (future use: metadata)
        """
        street_geocoder_searches = []
        for search in decoded_searches:
            search_id, address, city, state, country = \
                [search.get(k, None) for k in self.SEARCH_KEYS]
            street_geocoder_searches.append(
                StreetGeocoderSearch(search_id, address, city, state, country))

        if len(street_geocoder_searches) > self.MAX_BATCH_SIZE:
            raise Exception("Batch size can't be larger than {}".format(self.MAX_BATCH_SIZE))
        try:
            if self._should_use_batch(street_geocoder_searches):
                return self._batch_geocode(street_geocoder_searches)
            else:
                return self._serial_geocode(street_geocoder_searches)
        except Exception as e:
            msg = "Error running geocode: {}".format(e)
            self._logger.error(msg, e)
            errors = [geocoder_error_response(msg)] * len(decoded_searches)
            results = []
            for s, r in zip(decoded_searches, errors):
                results.append((s['id'], r[0], r[1]))
            return results

    def _batch_geocode(self, street_geocoder_searches):
        raise NotImplementedError('Subclasses must implement _batch_geocode')

    def _serial_geocode(self, street_geocoder_searches):
        raise NotImplementedError('Subclasses must implement _serial_geocode')

    def _should_use_batch(self, street_geocoder_searches):
        return True



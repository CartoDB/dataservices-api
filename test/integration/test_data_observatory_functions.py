from unittest import TestCase
from nose.tools import assert_raises
from nose.tools import assert_not_equal, assert_in
from ..helpers.integration_test_helper import IntegrationTestHelper


class TestDataObservatoryFunctions(TestCase):

    def setUp(self):
        self.env_variables = IntegrationTestHelper.get_environment_variables()
        self.sql_api_url = "{0}://{1}.{2}/api/v1/sql".format(
            self.env_variables['schema'],
            self.env_variables['username'],
            self.env_variables['host'],
        )

    def test_if_get_demographic_snapshot_is_ok(self):
        query = "SELECT obs_GetDemographicSnapshot(CDB_LatLng(40.704512, -73.936669)) as snapshot;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['snapshot'], None)

    def test_if_get_demographic_snapshot_without_api_key_raise_error(self):
        query = "SELECT obs_GetDemographicSnapshot(CDB_LatLng(40.704512, -73.936669));"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getdemographicsnapshot(geometry) does not exist"])

    def test_if_get_segment_snapshot_is_ok(self):
        query = "SELECT OBS_GetSegmentSnapshot(CDB_LatLng(40.704512, -73.936669)) as snapshot;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['snapshot'], None)

    def test_if_get_segment_snapshot_without_api_key_raise_error(self):
        query = "SELECT OBS_GetSegmentSnapshot(CDB_LatLng(40.704512, -73.936669));"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getsegmentsnapshot(geometry) does not exist"])

    def test_if_get_measure_with_point_is_ok(self):
        query = "SELECT OBS_GetMeasure(CDB_LatLng(40.704512, -73.936669), 'us.census.acs.B01003001') as measure;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['measure'], None)

    def test_if_get_measure_with_area_is_ok(self):
        query = "SELECT OBS_GetMeasure('0103000020E61000000100000021000000BB366F6D917B52C0E7BB6EA82B5A444067224C85937B52C0810205E70E5A4440596D6342997B52C09BED2952F35944400A96386CA27B52C07B6D31F9D95944402B81A0A8AE7B52C0D16B73D5C3594440C34C397FBD7B52C0D8B5B7C0B1594440CFD90A5ECE7B52C0BE8DD86CA45944405C7E229FE07B52C0A904EE5C9C59444017C1F28EF37B52C05E2745E099594440AE8A3873067C52C0FD62540F9D5944402F272292187C52C05502CBCAA5594440C3F17139297C52C0B3FBC4BCB3594440DDAE56C5377C52C00C46175CC6594440E96AB6A6437C52C0355C94F1DC5944402313AE684C7C52C05340159FF6594440B3B90FB5517C52C031F30168125A44407F43B357537C52C0DF95053B2F5A444059C17840517C52C0D9E08EFC4B5A44406580E8834B7C52C046B5B591675A444035736A5A427C52C0AF9A1AEB805A44402E721C1E367C52C0D226550F975A4440506D5C47277C52C0A2968A24A95A4440507C2868167C52C0D51FCE78B65A4440C4438226047C52C02369F888BE5A4440C9F10C36F17B52C027B1B205C15A4440AABE2451DE7B52C0F5E383D6BD5A44402A18B431CC7B52C01785C11AB55A444018320D8ABB7B52C070265B28A75A4440E28A0EFEAC7B52C09E518C88945A44401D08D61CA17B52C09E8195F27D5A4440D7C3405B987B52C0643CB044645A444047B16D0F937B52C04EC9837B485A4440BB366F6D917B52C0E7BB6EA82B5A4440'::geometry, 'us.census.acs.B01003001') as measure;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['measure'], None)

    def test_if_get_measure_without_api_key_raise_error(self):
        query = "SELECT OBS_GetMeasure(CDB_LatLng(40.704512, -73.936669), 'us.census.acs.B01003001');"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getmeasure(geometry, unknown) does not exist"])

    def test_if_get_measure_by_id_ok(self):
        query = "SELECT OBS_GetMeasureById('36047048500', 'us.census.acs.B01003001', 'us.census.tiger.census_tract', '2010 - 2014') as measure;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['measure'], None)

    def test_if_get_measure_by_id_without_api_key_raise_error(self):
        query = "SELECT OBS_GetMeasureById('36047048500', 'us.census.acs.B01003001', 'us.census.tiger.census_tract', '2010 - 2014') as measure"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getmeasurebyid(unknown, unknown, unknown, unknown) does not exist"])

    def test_if_get_category_is_ok(self):
        query = "SELECT OBS_GetCategory(CDB_LatLng(40.704512, -73.936669), 'us.census.spielman_singleton_segments.X10', 'us.census.tiger.census_tract', '2010 - 2014') as category;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['category'], None)

    def test_if_get_category_without_api_key_raise_error(self):
        query = "SELECT OBS_GetCategory(CDB_LatLng(40.704512, -73.936669), 'us.census.spielman_singleton_segments.X10', 'us.census.tiger.census_tract', '2010 - 2014');"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getcategory(geometry, unknown, unknown, unknown) does not exist"])

    def test_if_get_us_census_measure_with_point_is_ok(self):
        query = "SELECT OBS_GetUSCensusMeasure(CDB_LatLng(40.704512, -73.936669), 'male population') as measure;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['measure'], None)

    def test_if_get_us_census_measure_with_area_is_ok(self):
        query = "SELECT OBS_GetUSCensusMeasure('0103000020E61000000100000021000000BB366F6D917B52C0E7BB6EA82B5A444067224C85937B52C0810205E70E5A4440596D6342997B52C09BED2952F35944400A96386CA27B52C07B6D31F9D95944402B81A0A8AE7B52C0D16B73D5C3594440C34C397FBD7B52C0D8B5B7C0B1594440CFD90A5ECE7B52C0BE8DD86CA45944405C7E229FE07B52C0A904EE5C9C59444017C1F28EF37B52C05E2745E099594440AE8A3873067C52C0FD62540F9D5944402F272292187C52C05502CBCAA5594440C3F17139297C52C0B3FBC4BCB3594440DDAE56C5377C52C00C46175CC6594440E96AB6A6437C52C0355C94F1DC5944402313AE684C7C52C05340159FF6594440B3B90FB5517C52C031F30168125A44407F43B357537C52C0DF95053B2F5A444059C17840517C52C0D9E08EFC4B5A44406580E8834B7C52C046B5B591675A444035736A5A427C52C0AF9A1AEB805A44402E721C1E367C52C0D226550F975A4440506D5C47277C52C0A2968A24A95A4440507C2868167C52C0D51FCE78B65A4440C4438226047C52C02369F888BE5A4440C9F10C36F17B52C027B1B205C15A4440AABE2451DE7B52C0F5E383D6BD5A44402A18B431CC7B52C01785C11AB55A444018320D8ABB7B52C070265B28A75A4440E28A0EFEAC7B52C09E518C88945A44401D08D61CA17B52C09E8195F27D5A4440D7C3405B987B52C0643CB044645A444047B16D0F937B52C04EC9837B485A4440BB366F6D917B52C0E7BB6EA82B5A4440'::geometry, 'male population') as measure;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['measure'], None)

    def test_if_get_us_census_measure_without_api_key_raise_error(self):
        query = "SELECT OBS_GetUSCensusMeasure('0103000020E61000000100000021000000BB366F6D917B52C0E7BB6EA82B5A444067224C85937B52C0810205E70E5A4440596D6342997B52C09BED2952F35944400A96386CA27B52C07B6D31F9D95944402B81A0A8AE7B52C0D16B73D5C3594440C34C397FBD7B52C0D8B5B7C0B1594440CFD90A5ECE7B52C0BE8DD86CA45944405C7E229FE07B52C0A904EE5C9C59444017C1F28EF37B52C05E2745E099594440AE8A3873067C52C0FD62540F9D5944402F272292187C52C05502CBCAA5594440C3F17139297C52C0B3FBC4BCB3594440DDAE56C5377C52C00C46175CC6594440E96AB6A6437C52C0355C94F1DC5944402313AE684C7C52C05340159FF6594440B3B90FB5517C52C031F30168125A44407F43B357537C52C0DF95053B2F5A444059C17840517C52C0D9E08EFC4B5A44406580E8834B7C52C046B5B591675A444035736A5A427C52C0AF9A1AEB805A44402E721C1E367C52C0D226550F975A4440506D5C47277C52C0A2968A24A95A4440507C2868167C52C0D51FCE78B65A4440C4438226047C52C02369F888BE5A4440C9F10C36F17B52C027B1B205C15A4440AABE2451DE7B52C0F5E383D6BD5A44402A18B431CC7B52C01785C11AB55A444018320D8ABB7B52C070265B28A75A4440E28A0EFEAC7B52C09E518C88945A44401D08D61CA17B52C09E8195F27D5A4440D7C3405B987B52C0643CB044645A444047B16D0F937B52C04EC9837B485A4440BB366F6D917B52C0E7BB6EA82B5A4440'::geometry, 'male population');"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getuscensusmeasure(geometry, unknown) does not exist"])

    def test_if_get_us_census_category_is_ok(self):
        query = "SELECT OBS_GetUSCensusCategory('0103000020E61000000100000021000000BB366F6D917B52C0E7BB6EA82B5A444067224C85937B52C0810205E70E5A4440596D6342997B52C09BED2952F35944400A96386CA27B52C07B6D31F9D95944402B81A0A8AE7B52C0D16B73D5C3594440C34C397FBD7B52C0D8B5B7C0B1594440CFD90A5ECE7B52C0BE8DD86CA45944405C7E229FE07B52C0A904EE5C9C59444017C1F28EF37B52C05E2745E099594440AE8A3873067C52C0FD62540F9D5944402F272292187C52C05502CBCAA5594440C3F17139297C52C0B3FBC4BCB3594440DDAE56C5377C52C00C46175CC6594440E96AB6A6437C52C0355C94F1DC5944402313AE684C7C52C05340159FF6594440B3B90FB5517C52C031F30168125A44407F43B357537C52C0DF95053B2F5A444059C17840517C52C0D9E08EFC4B5A44406580E8834B7C52C046B5B591675A444035736A5A427C52C0AF9A1AEB805A44402E721C1E367C52C0D226550F975A4440506D5C47277C52C0A2968A24A95A4440507C2868167C52C0D51FCE78B65A4440C4438226047C52C02369F888BE5A4440C9F10C36F17B52C027B1B205C15A4440AABE2451DE7B52C0F5E383D6BD5A44402A18B431CC7B52C01785C11AB55A444018320D8ABB7B52C070265B28A75A4440E28A0EFEAC7B52C09E518C88945A44401D08D61CA17B52C09E8195F27D5A4440D7C3405B987B52C0643CB044645A444047B16D0F937B52C04EC9837B485A4440BB366F6D917B52C0E7BB6EA82B5A4440'::geometry, 'Spielman-Singleton Segments: 10 Clusters') as category;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['category'], None)

    def test_if_get_us_census_category_without_api_key_raise_error(self):
        query = "SELECT OBS_GetUSCensusCategory('0103000020E61000000100000021000000BB366F6D917B52C0E7BB6EA82B5A444067224C85937B52C0810205E70E5A4440596D6342997B52C09BED2952F35944400A96386CA27B52C07B6D31F9D95944402B81A0A8AE7B52C0D16B73D5C3594440C34C397FBD7B52C0D8B5B7C0B1594440CFD90A5ECE7B52C0BE8DD86CA45944405C7E229FE07B52C0A904EE5C9C59444017C1F28EF37B52C05E2745E099594440AE8A3873067C52C0FD62540F9D5944402F272292187C52C05502CBCAA5594440C3F17139297C52C0B3FBC4BCB3594440DDAE56C5377C52C00C46175CC6594440E96AB6A6437C52C0355C94F1DC5944402313AE684C7C52C05340159FF6594440B3B90FB5517C52C031F30168125A44407F43B357537C52C0DF95053B2F5A444059C17840517C52C0D9E08EFC4B5A44406580E8834B7C52C046B5B591675A444035736A5A427C52C0AF9A1AEB805A44402E721C1E367C52C0D226550F975A4440506D5C47277C52C0A2968A24A95A4440507C2868167C52C0D51FCE78B65A4440C4438226047C52C02369F888BE5A4440C9F10C36F17B52C027B1B205C15A4440AABE2451DE7B52C0F5E383D6BD5A44402A18B431CC7B52C01785C11AB55A444018320D8ABB7B52C070265B28A75A4440E28A0EFEAC7B52C09E518C88945A44401D08D61CA17B52C09E8195F27D5A4440D7C3405B987B52C0643CB044645A444047B16D0F937B52C04EC9837B485A4440BB366F6D917B52C0E7BB6EA82B5A4440'::geometry, 'Spielman-Singleton Segments: 10 Clusters');"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getuscensuscategory(geometry, unknown) does not exist"])

    def test_if_get_population_is_ok(self):
        query = "SELECT OBS_GetPopulation(CDB_LatLng(40.704512, -73.936669)) as population;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['population'], None)

    def test_if_get_population_without_api_key_raise_error(self):
        query = "SELECT OBS_GetPopulation(CDB_LatLng(40.704512, -73.936669));"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getpopulation(geometry) does not exist"])

    def test_if_obs_search_is_ok(self):
        sql = "SELECT id FROM OBS_Search('total_pop') WHERE id LIKE 'es.ine%' LIMIT 1;"
        import urllib
        query = "{0}&api_key={1}".format(urllib.quote(sql), self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['id'], None)

    def test_if_obs_search_without_api_key_raise_error(self):
        query = "SELECT id FROM OBS_Search('total_pop') LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_search(unknown) does not exist"])

    def test_if_obs_get_available_boundaries_is_ok(self):
        query = "SELECT boundary_id FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.704512, -73.936669)) LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['boundary_id'], None)

    def test_if_obs_get_available_boundaries_without_api_key_raise_error(self):
        query = "SELECT boundary_id FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.704512, -73.936669)) LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getavailableboundaries(geometry) does not exist"])

    def test_if_obs_get_boundary_is_ok(self):
        query = "SELECT OBS_GetBoundary(CDB_LatLng(40.704512, -73.936669), 'us.census.tiger.census_tract') as boundary;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['boundary'], None)

    def test_if_obs_get_boundary_without_api_key_raise_error(self):
        query = "SELECT OBS_GetBoundary(CDB_LatLng(40.704512, -73.936669), 'us.census.tiger.census_tract') as boundary;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getboundary(geometry, unknown) does not exist"])

    def test_if_obs_get_boundary_id_is_ok(self):
        query = "SELECT OBS_GetBoundaryId(CDB_LatLng(40.704512, -73.936669), 'us.census.tiger.census_tract', '2015') as boundary_id;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['boundary_id'], None)

    def test_if_obs_get_boundary_id_without_api_key_raise_error(self):
        query = "SELECT OBS_GetBoundaryId(CDB_LatLng(40.704512, -73.936669), 'us.census.tiger.census_tract', '2015') as boundary_id;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getboundaryid(geometry, unknown, unknown) does not exist"])

    def test_if_obs_get_boundary_by_id_is_ok(self):
        query = "SELECT OBS_GetBoundaryById('36047', 'us.census.tiger.county', '2014') as boundary;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['boundary'], None)

    def test_if_obs_get_boundary_by_id_without_api_key_raise_error(self):
        query = "SELECT OBS_GetBoundaryById('36047', 'us.census.tiger.county', '2014') as boundary_id;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getboundarybyid(unknown, unknown, unknown) does not exist"])

    def test_if_obs_get_boundaries_by_geometry_is_ok(self):
        query = "SELECT geom_refs FROM OBS_GetBoundariesByGeometry(ST_MakeEnvelope(-73.9452409744,40.6988851644,-73.9280319214,40.7101254524,4326), 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['geom_refs'], None)

    def test_if_obs_get_boundaries_by_geometry_without_api_key_raise_error(self):
        query = "SELECT geom_refs FROM OBS_GetBoundariesByGeometry(ST_MakeEnvelope(-73.9452409744,40.6988851644,-73.9280319214,40.7101254524,4326), 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getboundariesbygeometry(geometry, unknown) does not exist"])

    def test_if_obs_get_boundaries_by_point_and_radius_is_ok(self):
        query = "SELECT geom_refs FROM OBS_GetBoundariesByPointAndRadius(CDB_LatLng(40.704512, -73.936669), 500, 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['geom_refs'], None)

    def test_if_obs_get_boundaries_by_point_and_radius_without_api_key_raise_error(self):
        query = "SELECT geom_refs FROM OBS_GetBoundariesByPointAndRadius(CDB_LatLng(40.704512, -73.936669), 500, 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getboundariesbypointandradius(geometry, integer, unknown) does not exist"])

    def test_if_obs_get_points_by_geometry_is_ok(self):
        query = "SELECT geom_refs FROM OBS_GetPointsByGeometry(ST_MakeEnvelope(-73.9452409744,40.6988851644,-73.9280319214,40.7101254524,4326), 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['geom_refs'], None)

    def test_if_obs_get_points_by_geometry_without_api_key_raise_error(self):
        query = "SELECT geom_refs FROM OBS_GetPointsByGeometry(ST_MakeEnvelope(-73.9452409744,40.6988851644,-73.9280319214,40.7101254524,4326), 'us.census.tiger.census_tract') ORDER BY geom_refs ASC LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getpointsbygeometry(geometry, unknown) does not exist"])

    def test_if_obs_get_points_by_point_and_radius_is_ok(self):
        query = "SELECT geom_refs FROM OBS_GetPointsByPointAndRadius(CDB_LatLng(40.704512, -73.936669), 500, 'us.census.tiger.census_tract', '2014') ORDER BY geom_refs ASC LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['geom_refs'], None)

    def test_if_obs_get_points_by_point_and_radius_without_api_key_raise_error(self):
        query = "SELECT geom_refs FROM OBS_GetPointsByPointAndRadius(CDB_LatLng(40.704512, -73.936669), 500, 'us.census.tiger.census_tract', '2014') ORDER BY geom_refs ASC LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getpointsbypointandradius(geometry, integer, unknown, unknown) does not exist"])

    def test_if_obs_get_legacy_builder_metadata_is_ok(self):
        query = "SELECT name FROM OBS_LegacyBuilderMetadata() LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['name'], None)

    def test_if_legacy_builder_metadata_without_api_key_raise_error(self):
        query = "SELECT name FROM OBS_LegacyBuilderMetadata() LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_legacybuildermetadata() does not exist"])

    def test_if_obs_get_available_numerators_is_ok(self):
        query = "SELECT numer_id FROM OBS_GetAvailableNumerators() LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['numer_id'], None)

    def test_if_obs_get_available_numerators_without_api_key_raise_error(self):
        query = "SELECT numer_id FROM OBS_GetAvailableNumerators() LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getavailablenumerators() does not exist"])

    def test_if_obs_get_available_denominators_is_ok(self):
        query = "SELECT denom_id FROM OBS_GetAvailableDenominators() LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['denom_id'], None)

    def test_if_obs_get_available_denominators_without_api_key_raise_error(self):
        query = "SELECT denom_id FROM OBS_GetAvailableDenominators() LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getavailabledenominators() does not exist"])

    def test_if_obs_get_available_geometries_is_ok(self):
        query = "SELECT geom_id FROM OBS_GetAvailableGeometries() LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['geom_id'], None)

    def test_if_obs_get_available_geometries_without_api_key_raise_error(self):
        query = "SELECT geom_id FROM OBS_GetAvailableGeometries() LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getavailablegeometries() does not exist"])

    def test_if_obs_get_available_timespans_is_ok(self):
        query = "SELECT timespan_id FROM OBS_GetAvailableTimespans() LIMIT 1;&api_key={0}".format(self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['timespan_id'], None)

    def test_if_obs_get_available_timespans_without_api_key_raise_error(self):
        query = "SELECT timespan_id FROM OBS_GetAvailableTimespans() LIMIT 1;"
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getavailabletimespans() does not exist"])

    def test_if_obs_get_meta_is_ok(self):
        params = '\'[{\"numer_id\": \"us.census.acs.B01003001\"}]\''
        query = "SELECT obs_getmeta(ST_SetSRID(ST_Point(-73.9, 40.7), 4326), {0}, 1, 1, 1000) as metadata LIMIT 1;&api_key={1}".format(params, self.env_variables['api_key'])
        result = IntegrationTestHelper.execute_query(self.sql_api_url, query)
        assert_not_equal(result['metadata'], None)

    def test_if_obs_get_meta_without_api_key_raise_error(self):
        params = '\'[{\"numer_id\": \"us.census.acs.B01003001\"}]\''
        query = "SELECT obs_getmeta(ST_SetSRID(ST_Point(-73.9, 40.7), 4326), {0}, 1, 1, 1000) LIMIT 1;".format(params)
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getmeta(geometry, unknown, integer, integer, integer) does not exist"])

    def test_if_obs_get_data_is_ok(self):
        params_1 = '\'[{\"numer_id\": \"us.census.acs.B01003001\", \"geom_id\": \"us.census.tiger.county\"}]\''
        params_2 = '\'[{\"numer_id\": \"us.census.acs.B01003001\"}]\''
        query_1 = "SELECT id as data_id FROM obs_getdata(ARRAY['36047'], obs_getmeta(st_setsrid(st_point(-73.9, 40.7), 4326), {0}, 1, 1, 1000)) LIMIT 1;&api_key={1}".format(params_1, self.env_variables['api_key'])
        query_2 = "SELECT id as data_id FROM obs_getdata(ARRAY[(ST_SetSRID(ST_Point(-73.9, 40.7), 4326), 1)::geomval], obs_getmeta(st_setsrid(st_point(-73.9, 40.7), 4326), {0})) LIMIT 1;&api_key={1}".format(params_2,self.env_variables['api_key'])
        result_1 = IntegrationTestHelper.execute_query(self.sql_api_url, query_1)
        assert_not_equal(result_1['data_id'], None)
        result_2 = IntegrationTestHelper.execute_query(self.sql_api_url, query_2)
        assert_not_equal(result_2['data_id'], None)

    def test_if_obs_get_data_without_api_key_raise_error(self):
        params_1 = '\'[{\"numer_id\": \"us.census.acs.B01003001\", \"geom_id\": \"us.census.tiger.county\"}]\'';
        params_2 = '\'[{\"numer_id\": \"us.census.acs.B01003001\"}]\''
        query_1 = "SELECT id as data_id FROM obs_getdata(ARRAY['36047'], obs_getmeta(st_setsrid(st_point(-73.9, 40.7), 4326), {0}, 1, 1, 1000)) LIMIT 1;".format(params_1)
        query_2 = "SELECT id as data_id FROM obs_getdata(ARRAY[(ST_SetSRID(ST_Point(-73.9, 40.7), 4326), 1)::geomval], obs_getmeta(st_setsrid(st_point(-73.9, 40.7), 4326), {0})) LIMIT 1;".format(params_2)
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query_1)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getmeta(geometry, unknown, integer, integer, integer) does not exist"])
        try:
            IntegrationTestHelper.execute_query(self.sql_api_url, query_2)
        except Exception as e:
            assert_in(e.message[0], ["Data Observatory permission denied", "function obs_getmeta(geometry, unknown) does not exist"])

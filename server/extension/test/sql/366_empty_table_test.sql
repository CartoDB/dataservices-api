\set ECHO none
\set VERBOSITY verbose
SET client_min_messages TO error;

-- Set configuration for a user 'foo'
DO $$
  import json
  from cartodb_services.config import ServiceConfiguration

  import cartodb_services
  cartodb_services.init(plpy, GD)

  service_config = ServiceConfiguration('observatory', 'foo', None)
  service_config.user.set('soft_obs_general_limit', True)
  service_config.user.set('period_end_date', '20170516')

$$ LANGUAGE @@plpythonu@@;


-- Mock Observatory backend function
CREATE SCHEMA cdb_observatory;
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetData(geomvals geomval[], params JSON, merge BOOLEAN DEFAULT TRUE)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
BEGIN
  -- this will return an empty set
  RAISE NOTICE 'Mocked OBS_GetData()';
END;
$$ LANGUAGE plpgsql;
GRANT USAGE ON SCHEMA cdb_observatory TO geocoder_api;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_observatory TO geocoder_api;


-- Test it
SELECT * FROM cdb_dataservices_server.OBS_GetData(
    'foo',
    NULL,
    '{"(0103000020E61000000100000005000000010000E0F67F52C096D88AE6B25F4440010000E0238052C0BF6D8A1A8D5D4440010000D0DA7E52C05F03F3CC265D444001000020F47E52C0F2DD78AB5D5F4440010000E0F67F52C096D88AE6B25F4440,1)"}'::public._geomval,
    '[{"id": 1, "score": 52.7515548093083898758340051256007949661290516400338, "geom_id": "us.census.tiger.census_tract", "denom_id": "us.census.acs.B01003001", "numer_id": "us.census.acs.B03002003", "geom_name": "US Census Tracts", "geom_type": "Geometry", "num_geoms": 2.86483076549783307739486952736, "denom_name": "Total Population", "denom_type": "Numeric", "numer_name": "White Population", "numer_type": "Numeric", "score_rank": 1, "target_area": 0.000307374806576033, "geom_colname": "the_geom", "score_rownum": 1, "target_geoms": null, "denom_colname": "total_pop", "denom_reltype": '
         '"denominator", "geom_timespan": "2015", "normalization": "prenormalized", "numer_colname": "white_pop", "timespan_rank": 1, "geom_tablename": "obs_87a814e485deabe3b12545a537f693d16ca702c2", "max_score_rank": null, "numer_timespan": "2010 - 2014", "suggested_name": "white_pop_2010_2014", "denom_aggregate": "sum", "denom_tablename": "obs_b393b5b88c6adda634b2071a8005b03c551b609a", "numer_aggregate": "sum", "numer_tablename": "obs_b393b5b88c6adda634b2071a8005b03c551b609a", "timespan_rownum": 1, "geom_description": "Census tracts are small, relatively permanent statistical subdivisions of a county or equivalent entity that are updated by local participants prior to each decennial census as part of the Census Bureau’s Participant Statistical Areas Program. The Census Bureau delineates census tracts in situations where no local participant existed or where state, local, or tribal governments'
         'declined to participate. The primary purpose of census tracts is to provide a stable set of geographic units for the presentation of statistical data.\r\n\r\nCensus tracts generally have a population size between 1,200 and 8,000 people, with an optimum size of 4,000 people. A census tract usually covers a contiguous area; however, the spatial size of census tracts varies widely depending on the density of settlement. Census tract boundaries are delineated with the intention of being maintained over a long time so that statistical comparisons can be made from census to census. Census tracts occasionally are split due to population growth or merged as a result of substantial population decline.\r\n\r\nCensus tract boundaries generally follow visible and identifiable features. They may follow nonvisible legal boundaries, such as minor civil division (MCD) or incorporated place boundaries'
         'in some states and situations, to allow for census-tract-to-governmental-unit relationships where the governmental boundaries tend to remain unchanged between censuses. State and county boundaries always are census tract boundaries in the standard census geographic hierarchy. Tribal census tracts are a unique geographic entity defined within federally recognized American Indian reservations and off-reservation trust lands and can cross state and county boundaries. Tribal census tracts may be completely different from the census tracts and block groups defined by state and county (see “Tribal Census Tract”).", "denom_description": "The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates.", "max_timespan_rank": null, "numer_description": "The number of people identifying as white, non-Hispanic in each'
         'geography.", "geom_t_description": null, "denom_t_description": null, "numer_t_description": null, "geom_geomref_colname": "geoid", "denom_geomref_colname": "geoid", "numer_geomref_colname": "geoid"}]'::json,
     true);



-- Mock another observatory backend function (overloaded, different params)
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetData(geomrefs TEXT[], params JSON)
RETURNS TABLE (
  id INT,
  data JSON
) AS $$
BEGIN
  -- this will return an empty set
  RAISE NOTICE 'Mocked OBS_GetData()';
END;
$$ LANGUAGE plpgsql;
GRANT USAGE ON SCHEMA cdb_observatory TO geocoder_api;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_observatory TO geocoder_api;

-- Test it
SELECT * FROM cdb_dataservices_server.OBS_GetData('foo', NULL, '{bar, baz}'::TEXT[], '[]'::JSON);

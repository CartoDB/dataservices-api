-- Add to the search path the schema
SET search_path TO public,cartodb,cdb_dataservices_client;

-- Mock the server functions

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_demographic_snapshot (username text, orgname text, geom geometry(Geometry, 4326), time_span text DEFAULT '2009 - 2013', geometry_level text DEFAULT '"us.census.tiger".block_group')
RETURNS json AS $$
DECLARE
  ret json;
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.obs_get_demographic_snapshot invoked with params (%, %, %, %, %)', username, orgname, geom, time_span, geometry_level;
  SELECT '{"total_pop":9516.27915900609,"male_pop":6152.51885204623,"female_pop":3363.76030695986,"median_age":28.8,"white_pop":5301.51624447348,"black_pop":149.500458087105,"asian_pop":230.000704749392,"hispanic_pop":3835.26175169611,"amerindian_pop":0,"other_race_pop":0,"two_or_more_races_pop":0,"not_hispanic_pop":5681.01740730998,"households":3323.51018362871,"pop_25_years_over":7107.02177675621,"high_school_diploma":1040.753188991,"less_one_year_college":69.0002114248176,"one_year_more_college":793.502431385402,"associates_degree":327.751004267883,"bachelors_degree":2742.7584041365,"masters_degree":931.502854235037,"median_income":66304,"gini_index":0.3494,"income_per_capita":28291,"housing_units":3662.76122313407,"vacant_housing_units":339.251039505353,"vacant_housing_units_for_rent":120.750369993431,"vacant_housing_units_for_sale":0,"median_rent":1764,"percent_income_spent_on_rent":35.3,"owner_occupied_housing_units":339.251039505353,"million_dollar_housing_units":0,"mortgaged_housing_units":224.250687130657,"commuters_16_over":6549.27006773893,"commute_less_10_mins":327.751004267883,"commute_10_14_mins":28.750088093674,"commute_15_19_mins":201.250616655718,"commute_20_24_mins":621.001902823358,"commute_25_29_mins":373.751145217762,"commute_30_34_mins":1851.5056732326,"commute_35_44_mins":1414.50433420876,"commute_45_59_mins":1115.50341803455,"commute_60_more_mins":615.251885204623,"aggregate_travel_time_to_work":null,"income_less_10000":57.500176187348,"income_10000_14999":0,"income_15000_19999":212.750651893187,"income_20000_24999":408.251250930171,"income_25000_29999":0,"income_30000_34999":155.25047570584,"income_35000_39999":109.250334755961,"income_40000_44999":92.0002818997568,"income_45000_49999":63.2501938060828,"income_50000_59999":184.000563799514,"income_60000_74999":621.001902823358,"income_75000_99999":552.001691398541,"income_100000_124999":327.751004267883,"income_125000_149999":333.501021886618,"income_150000_199999":126.500387612166,"income_200000_or_more":null,"land_area":null}'::json INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_server.obs_get_segment_snapshot (username text, orgname text, geom geometry(Geometry, 4326), geometry_level text DEFAULT '"us.census.tiger".census_tract')
RETURNS json AS $$
DECLARE
  ret json;
BEGIN
  RAISE NOTICE 'cdb_dataservices_server.obs_get_segment_snapshot invoked with params (%, %, %, %)', username, orgname, geom, geometry_level;
  SELECT '{"total_pop":9516.27915900609,"male_pop":6152.51885204623,"female_pop":3363.76030695986,"median_age":28.8,"white_pop":5301.51624447348,"black_pop":149.500458087105,"asian_pop":230.000704749392,"hispanic_pop":3835.26175169611,"amerindian_pop":0,"other_race_pop":0,"two_or_more_races_pop":0,"not_hispanic_pop":5681.01740730998,"households":3323.51018362871,"pop_25_years_over":7107.02177675621,"high_school_diploma":1040.753188991,"less_one_year_college":69.0002114248176,"one_year_more_college":793.502431385402,"associates_degree":327.751004267883,"bachelors_degree":2742.7584041365,"masters_degree":931.502854235037,"median_income":66304,"gini_index":0.3494,"income_per_capita":28291,"housing_units":3662.76122313407,"vacant_housing_units":339.251039505353,"vacant_housing_units_for_rent":120.750369993431,"vacant_housing_units_for_sale":0,"median_rent":1764,"percent_income_spent_on_rent":35.3,"owner_occupied_housing_units":339.251039505353,"million_dollar_housing_units":0,"mortgaged_housing_units":224.250687130657,"commuters_16_over":6549.27006773893,"commute_less_10_mins":327.751004267883,"commute_10_14_mins":28.750088093674,"commute_15_19_mins":201.250616655718,"commute_20_24_mins":621.001902823358,"commute_25_29_mins":373.751145217762,"commute_30_34_mins":1851.5056732326,"commute_35_44_mins":1414.50433420876,"commute_45_59_mins":1115.50341803455,"commute_60_more_mins":615.251885204623,"aggregate_travel_time_to_work":null,"income_less_10000":57.500176187348,"income_10000_14999":0,"income_15000_19999":212.750651893187,"income_20000_24999":408.251250930171,"income_25000_29999":0,"income_30000_34999":155.25047570584,"income_35000_39999":109.250334755961,"income_40000_44999":92.0002818997568,"income_45000_49999":63.2501938060828,"income_50000_59999":184.000563799514,"income_60000_74999":621.001902823358,"income_75000_99999":552.001691398541,"income_100000_124999":327.751004267883,"income_125000_149999":333.501021886618,"income_150000_199999":126.500387612166,"income_200000_or_more":null,"land_area":null}'::json INTO ret;
  RETURN ret;
END;
$$ LANGUAGE 'plpgsql';


-- Exercise the public and the proxied function
SELECT obs_get_demographic_snapshot('POINT(-87.81406 41.89308)'::geometry);
SELECT obs_get_segment_snapshot('POINT(-87.81406 41.89308)'::geometry);
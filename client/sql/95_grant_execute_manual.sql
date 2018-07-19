GRANT EXECUTE ON FUNCTION cdb_dataservices_client._DST_PrepareTableOBS_GetMeasure(output_table_name text, params json) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._DST_PopulateTableOBS_GetMeasure(table_name text, output_table_name text, params json) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._OBS_PreCheck(source_query text, params JSON) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_bulk_geocode_street_point(query text, street_column text, city_column text, state_column text, country_column text, batch_size integer) TO publicuser;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_count_estimate(query text) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.cdb_jsonb_array_casttext(jsonb) TO publicuser;

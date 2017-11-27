CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_PreCheck(
    source_query text,
    parameters json
) RETURNS boolean AS $$
DECLARE
    errors text[];
    validator_errors text[];
    validator_error text;
    valid boolean;
    geoms record;
BEGIN
    errors := (ARRAY[])::TEXT[];
    FOR geoms IN EXECUTE format('SELECT ST_GeometryType(the_geom) as geom_type,
                                 bool_and(st_isvalid(the_geom)) as valid,
                                 avg(st_npoints(the_geom)) as avg_vertex,
                                 ST_SetSRID(ST_Extent(the_geom), 4326) as extent,
                                 count(*)::INT as numgeoms
                                 FROM (%s) as _source
                                 GROUP BY ST_GeometryType(the_geom)', source_query)
    LOOP
        IF geoms.geom_type NOT IN ('ST_Polygon', 'ST_MultiPolygon', 'ST_Point') THEN
            errors := array_append(errors, format($data$'Geometry type %s not supported'$data$, geoms.geom_type));
        END IF;

        IF geoms.valid IS FALSE THEN
            errors := array_append(errors, 'There are invalid geometries in the input data, please try to fix them');
        END IF;

        -- 1000 vertex for a geometry is a limit we have in the obs_getdata function. You can check here
        -- https://github.com/CartoDB/observatory-extension/blob/1.6.0/src/pg/sql/41_observatory_augmentation.sql#L813
        IF geoms.avg_vertex > 1000 THEN
            errors := array_append(errors, 'The average number of vertices per geometry is greater than 1000, please try to simplify them');
        END IF;

        -- OBS specific part
        EXECUTE 'SELECT valid, errors
        FROM cdb_dataservices_client.OBS_MetadataValidation($1, $2, $3, $4)'
        INTO valid, validator_errors
        USING geoms.extent, geoms.geom_type, parameters, geoms.numgeoms;
        IF valid is FALSE THEN
            FOR validator_error IN EXECUTE 'SELECT unnest($1)' USING validator_errors
            LOOP
                errors := array_append(errors, validator_error);
            END LOOP;
        END IF;
    END LOOP;

    IF CARDINALITY(errors) > 0 THEN
        RAISE EXCEPTION '%', errors;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql' VOLATILE PARALLEL UNSAFE;

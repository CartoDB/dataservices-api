CREATE OR REPLACE FUNCTION cdb_dataservices_client._OBS_PreCheck(
    source_query text,
    parameters jsonb
) RETURNS boolean AS $$
DECLARE
    username text;
    orgname text;
    errors text[];
    geoms record;
BEGIN
    errors := (ARRAY[])::TEXT[];
    FOR geoms IN
    EXECUTE FORMAT('SELECT ST_GeometryType(the_geom) as geom_type,
                    bool_and(st_isvalid(the_geom)) as valid,
                    avg(st_npoints(the_geom)) as avg_vertex
                    FROM (%s) as _source GROUP BY ST_GeometryType(the_geom)', source_query)
    LOOP
        IF geoms.geom_type NOT IN ('ST_Polygon', 'ST_MultiPolygon', 'ST_Point') THEN
            errors := array_append(errors, format($data$'Geometry type %s not supported'$data$, geoms.geom_type));
        END IF;

        IF geoms.valid IS FALSE THEN
            errors := array_append(errors, 'There are invalid geometries in the input data, please review them');
        END IF;

        -- 1000 vertex for a geometry is a limit we have in the obs_getdata function. You can check here
        -- https://github.com/CartoDB/observatory-extension/blob/1.6.0/src/pg/sql/41_observatory_augmentation.sql#L813
        IF geoms.avg_vertex > 1000 THEN
            errors := array_append(errors, 'The average number of geometries vertex is greater than 1000, please try to simplify them');
        END IF;
    END LOOP;

    IF CARDINALITY(errors) > 0 THEN
        RAISE EXCEPTION '%', format('%s', errors);
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

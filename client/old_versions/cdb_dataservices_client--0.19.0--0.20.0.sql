--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION cdb_dataservices_client UPDATE TO '0.20.0'" to load this file. \quit

-- Make sure we have a sane search path to create/update the extension
SET search_path = "$user",cartodb,public,cdb_dataservices_client;

-- HERE goes your code to upgrade/downgrade
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
            errors := array_append(errors, 'There are invalid geometries in the input data, please review them');
        END IF;

        -- 1000 vertex for a geometry is a limit we have in the obs_getdata function. You can check here
        -- https://github.com/CartoDB/observatory-extension/blob/1.6.0/src/pg/sql/41_observatory_augmentation.sql#L813
        IF geoms.avg_vertex > 1000 THEN
            errors := array_append(errors, 'The average number of geometries vertex is greater than 1000, please try to simplify them');
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
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_metadatavalidation (username text, orgname text, geom_extent Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
  CONNECT cdb_dataservices_client._server_conn_str();
  SELECT * FROM cdb_dataservices_server.obs_metadatavalidation (username, orgname, geom_extent, geom_type, params, target_geoms);
$$ LANGUAGE plproxy;

CREATE OR REPLACE FUNCTION cdb_dataservices_client.obs_metadatavalidation (geom_extent Geometry(Geometry, 4326) ,geom_type text ,params json ,target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
DECLARE
  username text;
  orgname text;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;

  RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_metadatavalidation(username, orgname, geom_extent, geom_type, params, target_geoms);
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_dataservices_client._obs_metadatavalidation_exception_safe (geom_extent Geometry(Geometry, 4326) ,geom_type text ,params json ,target_geoms integer DEFAULT NULL)
RETURNS TABLE(valid boolean, errors text[]) AS $$
DECLARE
  username text;
  orgname text;
  _returned_sqlstate TEXT;
  _message_text TEXT;
  _pg_exception_context TEXT;
BEGIN
  IF session_user = 'publicuser' OR session_user ~ 'cartodb_publicuser_*' THEN
    RAISE EXCEPTION 'The api_key must be provided';
  END IF;
  SELECT u, o INTO username, orgname FROM cdb_dataservices_client._cdb_entity_config() AS (u text, o text);
  -- JSON value stored "" is taken as literal
  IF username IS NULL OR username = '' OR username = '""' THEN
    RAISE EXCEPTION 'Username is a mandatory argument, check it out';
  END IF;
  BEGIN
    RETURN QUERY SELECT * FROM cdb_dataservices_client._obs_metadatavalidation(username, orgname, geom_extent, geom_type, params, target_geoms);
  EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS _returned_sqlstate = RETURNED_SQLSTATE,
                                _message_text = MESSAGE_TEXT,
                                _pg_exception_context = PG_EXCEPTION_CONTEXT;
        RAISE WARNING USING ERRCODE = _returned_sqlstate, MESSAGE = _message_text, DETAIL = _pg_exception_context;

  END;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION cdb_dataservices_client._OBS_PreCheck(source_query text, params JSON) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client.obs_metadatavalidation(geom_extent Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer) TO publicuser;
GRANT EXECUTE ON FUNCTION cdb_dataservices_client._obs_metadatavalidation_exception_safe(geom_extent Geometry(Geometry, 4326), geom_type text, params json, target_geoms integer )  TO publicuser;


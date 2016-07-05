# Isoline Functions

[Isolines](https://carto.com/data/isolines/) are contoured lines that display equally calculated levels over a given surface area. This enables you to view polygon dimensions by forward or reverse measurements. Isoline functions are calculated as the intersection of areas from the origin point, measured by distance (isodistance) or time (isochrone). For example, the distance of a road from a sidewalk. Isoline services through CARTO are available by requesting a single function in the Data Services API.

_**This service is subject to quota limitations and extra fees may apply**. View the [Quota Information](https://carto.com/docs/carto-engine/dataservices-api/quota-information/) section for details and recommendations about to quota consumption._

You can use the isoline functions to retrieve, for example, isochrone lines from a certain location, specifying the mode and the ranges that will define each of the isolines. The following query calculates isolines for areas that are 5, 10 and 15 minutes (300, 600 and 900 seconds, respectively) away from the location by following a path defined by car routing and inserts them into a table.

```bash
https://{username}.carto.com/api/v2/sql?q=INSERT INTO {table} (the_geom) SELECT  the_geom FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[300, 600, 900]::integer[])&api_key={api_key}
```

The following functions provide an isoline generator service, based on time or distance. This service uses the isolines service defined for your account. The default service limits the usage of displayed polygons represented on top of [HERE](https://developer.here.com/coverage-info) maps.

## cdb_isodistance(_source geometry, mode text, range integer[], [options text[]]_)

Displays a contoured line on a map, connecting geometries to a defined area, measured by an equal range of distance (in meters).

#### Arguments

Name | Type | Description | Accepted values
--- | --- | --- | ---
`source` | `geometry` | Source point, in 4326 projection, which defines the start location. |
`mode` | `text` | Type of transport used to calculate the isolines. | `car` or `walk`
`range` | `integer[]` | Range of the isoline, in meters. |
`options` | `text[]` | (Optional) Multiple options to add more capabilities to the analysis. See [Optional isolines parameters](#optional-isoline-parameters) for details.


#### Returns

Name | Type | Description
--- | --- | ---
`center` | `geometry` | Source point, in 4326 projection, which defines the start location.
`data_range` | `integer` | The range that belongs to the generated isoline.
`the_geom` | `geometry(MultiPolygon)` | MultiPolygon geometry of the generated isoline in the 4326 projection.

#### Examples

##### Calculate and insert isodistance polygons from a point into another table

```bash
INSERT INTO {table} (the_geom) SELECT  the_geom FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, 'walk', ARRAY[300, 600, 900]::integer[])
```

or equivalently:

```bash
INSERT INTO {table} (the_geom) SELECT (cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, 'walk', ARRAY[300, 600, 900]::integer[])).the_geom
```

##### Calculate and insert the generated isolines from `points_table` table to another table

```bash
INSERT INTO {table} (the_geom) SELECT (cdb_isodistance(the_geom, 'walk', string_to_array(distance, ',')::integer[])).the_geom FROM {points_table}
```


## cdb_isochrone(_source geometry, mode text, range integer[], [options text[]]_)

Displays a contoured line on a map, connecting geometries to a defined area, measured by an equal range of time (in seconds).

#### Arguments

This function uses the same parameters and information as the `cdb_isodistance` function, with the exception that the range is measured in seconds instead of meters.

Name | Type | Description | Accepted values
--- | --- | --- | ---
`source` | `geometry` | Source point, in 4326 projection, which defines the start location. |
`mode` | `text` | Type of transport used to calculate the isolines. | `car` or `walk`
`range` | `integer[]` | Range of the isoline, in seconds. |
`options` | `text[]` | (Optional) Multiple options to add more capabilities to the analysis. See [Optional isolines parameters](#optional-isoline-parameters) for details.

#### Examples

##### Calculate and insert isochrone polygons from a point into another table

```bash
INSERT INTO {table} (the_geom) SELECT  the_geom FROM cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[300, 900, 12000]::integer[], ARRAY['mode_traffic=enabled','quality=3']::text[])
```

or equivalently:

```bash
INSERT INTO {table} (the_geom) SELECT (cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[300, 900, 12000]::integer[], ARRAY['mode_traffic=enabled','quality=3']::text[])).the_geom
```

##### Calculate and insert the generated isolines from `points_table` table into another table

```bash
INSERT INTO {table} (the_geom) SELECT (cdb_isochrone(the_geom, 'walk', string_to_array(time_distance, ',')::integer[])).the_geom FROM {points_table}
```

### Optional isoline parameters

The optional value parameters must be passed using the format: `option=value`.

Name | Type | Description | Accepted values
--- | --- | --- | ---
`is_destination` | `boolean` | If true, the source point is the destination instead of the starting location | `true` or `false`. `false` by default
`mode_type` | `text` | Type of route calculation | `shortest` or `fastest`. `shortest` by default
`mode_traffic` | `text` | Use traffic data to calculate the route | `enabled` or `disabled`. `disabled` by default
`resolution` | `text` | Allows you to specify the level of detail needed for the isoline polygon. Unit is meters per pixel. Higher resolution may increase the response time of the service.
`maxpoints` | `text` | Allows you to limit the amount of points in the returned isoline. If the isoline consists of multiple components, the sum of points from all components is considered. Each component will have at least two points. It is possible that more points than specified could be returned, in case when `2 * number of components` is higher than the `maxpoints` value itself. Increasing the number of `maxpoints` may increase the response time of the service.
`quality` | `text` | Allows you to reduce the quality of the isoline in favor of the response time. | `1`, `2`, `3`. Default value is `1`, corresponding to the best quality option.

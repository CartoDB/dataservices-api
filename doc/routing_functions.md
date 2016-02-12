
# Routing functions

The following rouging functions are available, grouped by categories.

## Isolines

This function provides an isolines generator sirves based on time or distance.

### cdb_isodistance(_source geometry, mode text, range integer[], options text[]_)

#### Arguments

Name | Type | Description | Accepted values
--- | --- | --- | ---
`source` | `geometry` | Source point, in 4326 projection, taken as the start point
`mode` | `geometry` | Type of transport used to calculate the isolines. | `car` and `walk`
`range` | `integer[]` | Range of the isoline in meters
`options` | `text[]` | Multiple options to add more capabilities to the analysis. See the options section to know more.

#### Options

The options values must be pass in the following way: `option=value`.

Name | Type | Description | Accepted values
--- | --- | --- | ---
`is_destination` | `boolean` | If is true the source point is the destination instead of the starting one.
`mode_type` | `text` | Type of route calculation | `shortest` or `fastest`. By default is `shortest`
`mode_traffic` | `text` | Use the traffic data to calculate the route. | `enabled` or `disabled`. By default is `disabled`
`singlecomponent` | `boolean` | If set to true the isoline service will always return single polygon, instead of creating a separate polygon for each ferry separated island. | `true` or `false`. Default value is false. 
`resolution` | `text` | Allows to specify level of detail needed for the isoline polygon. Unit is meters per pixel. Higher resolution may cause increased response time from the service.
`maxpoints` | `text` | Allows to limit amount of points in the returned isoline. If isoline consists of multiple components, sum of points from all components is considered. Each component will have at least 2 points, so it is possible that more points than maxpoints value will be returned. This is in case when 2 * number of components is higher than maxpoints. Enlarging number of maxpoints may cause increased response time from the service.
`quality` | `text` | Allows to reduce the quality of the isoline in favor of the response time. | `1`, `2`, `3`. Default value is 1 and it is the best quality.

#### Returns

Name | Type | Description
--- | --- | ---
`center` | `geometry` | Source point, in 4326 projection, taken as the start point
`data_range` | `integer` | The range that belongs to the generated isoline. 
`the_geom` | `geometry (multipolygon)` | Geometry of the generated isoline in 4326 projection. 

#### Example

##### Select

```bash
SELECT * FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[1000,2000]::integer[]);
SELECT * FROM cdb_isodistance('POINT(-3.70568 40.42028)'::geometry, 'walk', ARRAY[1000]::integer[], ARRAY['mode_traffic=enabled','quality=3']::text[]);
```

### cdb_isochrone(_source geometry, mode text, range integer[], options text[]_)

This function uses the same parameters and info as the `cdb_isodistance` function with the difference that the range is measured in seconds instead of meters

#### Example

##### Select

```bash
SELECT * FROM cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, 'car', ARRAY[300,900,12000]::integer[]);
SELECT * FROM cdb_isochrone('POINT(-3.70568 40.42028)'::geometry, 'walk', ARRAY[300,900]::integer[], ARRAY['mode_traffic=enabled','quality=3']::text[]);
```

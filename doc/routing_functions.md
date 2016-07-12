# Routing Functions

Routing is the navigation from a defined start location to a defined end location. The calculated results are displayed as turn-by-turn directions on your map, based on the transportation mode that you specified. Routing services through CARTO are available by using the available functions in the Data Services API.

## cdb_route_point_to_point(_origin geometry(Point), destination geometry(Point), mode text, [options text[], units text]_)

Returns a route from origin to destination.

#### Arguments

Name | Type | Description | Accepted values
--- | --- | --- | ---
`origin` | `geometry(Point)` | Origin point, in 4326 projection, which defines the start location. |
`destination` | `geometry(Point)` | Destination point, in 4326 projection, which defines the end location. |
`mode` | `text` | Type of transport used to calculate the isolines. | `car`, `walk`, `bicycle` or `public_transport`
`options` | `text[]` | (Optional) Multiple options to add more capabilities to the analysis. See [Optional routing parameters](#optional-routing-parameters) for details.
`units` | `text` | Unit used to represent the length of the route. | `kilometers`, `miles`. By default is `kilometers`


#### Returns

Name | Type | Description
--- | --- | ---
`duration` | `integer` | Duration in seconds of the calculated route.
`length` | `real` | Length in the defined unit in the `units` field. `kilometers` by default .
`the_geom` | `geometry(LineString)` | LineString geometry of the calculated route in the 4326 projection.

#### Examples

##### Insert the values from the calculated route in your table

```bash
INSERT INTO <TABLE> (duration, length, the_geom) SELECT duration, length, shape FROM cdb_route_point_to_point('POINT(-3.70237112 40.41706163)'::geometry,'POINT(-3.69909883 40.41236875)'::geometry, 'car')
```
##### Update the geometry field with the calculated route shape

```bash
UPDATE <TABLE> SET the_geom = (SELECT shape FROM cdb_route_point_to_point('POINT(-3.70237112 40.41706163)'::geometry,'POINT(-3.69909883 40.41236875)'::geometry, 'car', ARRAY['mode_type=shortest']::text[]))
```

## cdb_route_with_waypoints(_waypoints geometry(Point)[], mode text, [options text[], units text]_)

Returns a route that goes from origin to destination and whose path travels through the defined locations.

#### Arguments

Name | Type | Description | Accepted values
--- | --- | --- | ---
`waypoints` | `geometry(Point)[]` | Array of ordered points, in 4326 projection, which defines the origin point, one or more locations for the route path to travel through, and the destination. The first element of the array defines the origin and the last element the destination of the route. |
`mode` | `text` | Type of transport used to calculate the isolines. | `car`, `walk`, `bicycle` or `public_transport`
`options` | `text[]` | (Optional) Multiple options to add more capabilities to the analysis. See [Optional routing parameters](#optional-routing-parameters) for details.
`units` | `text` | Unit used to represent the length of the route. | `kilometers`, `miles`. By default is `kilometers`


#### Returns

Name | Type | Description
--- | --- | ---
`duration` | `integer` | Duration in seconds of the calculated route.
`length` | `real` | Length in the defined unit in the `units` field. `kilometers` by default .
`the_geom` | `geometry(LineString)` | LineString geometry of the calculated route in the 4326 projection.

*Note*: A request to the function _cdb\_route\_with\_waypoints(waypoints geometry(Point)[], mode text, [options text[], units text])_ with only two points in the geometry array are automatically defined as origin and destination. It is equivalent to performing the following request with these two locations as parameters: _cdb\_route\_point\_to\_point(origin geometry(Point), destination geometry(Point), mode text, [options text[], units text])_.

#### Examples

##### Insert the values from the calculated route in your table

```bash
INSERT INTO <TABLE> (duration, length, the_geom) SELECT duration, length, shape FROM cdb_route_with_waypoints(Array['POINT(-3.7109 40.4234)'::GEOMETRY, 'POINT(-3.7059 40.4203)'::geometry, 'POINT(-3.7046 40.4180)'::geometry]::geometry[], 'walk')
```
##### Update the geometry field with the calculated route shape

```bash
UPDATE <TABLE> SET the_geom = (SELECT shape FROM cdb_route_with_waypoints(Array['POINT(-3.7109 40.4234)'::GEOMETRY, 'POINT(-3.7059 40.4203)'::geometry, 'POINT(-3.7046 40.4180)'::geometry]::geometry[], 'car', ARRAY['mode_type=shortest']::text[]))
```


### Optional routing parameters

The optional value parameters must be passed using the format: `option=value`.

Name | Type | Description | Accepted values
--- | --- | --- | ---
`mode_type` | `text` | Type of route calculation | `shortest` (this option only applies to the car transport mode)

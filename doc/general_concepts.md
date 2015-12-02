# General concepts

The Geocoder API offers geocoding services on top of the CartoDB SQL API by means of a set of geocoding functions. Each one of these functions is oriented to one kind of geocoding operation and it will return the corresponding geometry (a `polygon` or a `point`) according to the input information.

The Geocoder API decouples the geocoding service from the CartoDB Editor, and allows to geocode data (being single rows, complete datasets or simple inputs) programatically through authenticated requests.

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/).

The Geocoder API can return different types of geometries (points or polygons) as result of different geocoding processes. The CartoDB platform does not support multigeometry layers or datasets, therefore the final users of this Geocoder API must check that they are using consistent geometry types inside a table to avoid further conflicts in the map visualization.

#### Authentication

All requests performed to the CartoDB Geocoder API must be authenticated with the user API Key. For more information about where to find your API Key, and how to authenticate your SQL API requests, view the [SQL API authentication](/cartodb-platform/sql-api/authentication/) guide.

#### Errors

Errors are described in the response of the geocoder request. An example is as follows:

```json
{
  error: [
    "function cdb_geocode_countries(text) does not exist"
  ]
}
```

Since the Geocoder API is used on top of the CartoDB SQL API, you can refer to the [Making calls to the SQL API](/cartodb-platform/sql-api/making-calls/) documentation for help debugging your SQL errors.

If the requested information is not in the CartoDB geocoding database, or if CartoDB is unable to recognize your input and match it with a result, the geocoding function returns `null` as a result.

#### Limits

Usage of the Geocoder API is subject to the CartoDB SQL API limits, stated in our [Terms of Service](https://cartodb.com/terms/#excessive).

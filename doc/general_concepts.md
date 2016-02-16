# General concepts

The Data Services API offers geocoding and routing services on top of the CartoDB SQL API by means of a set of functions. Each one of these functions is oriented to one kind of operation and returns the corresponding geometry (a `polygon` or a `point`), according to the input information.

The Data Services API decouples the geocoding and routing services from the CartoDB Editor. The API allows you to geocode data (from single rows, complete datasets, or simple inputs) and to perform trade areas analysis (computing isodistances or isochrones) programatically through authenticated requests.

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/).

The Geocoder functions can return different types of geometries (points or polygons) as result of different geocoding processes. The CartoDB platform does not support multigeometry layers or datasets, therefore the final users of this Data Services API must check that they are using consistent geometry types inside a table to avoid further conflicts in the map visualization.

## Authentication

All requests performed to the CartoDB Data Services API must be authenticated with the user API Key. For more information about where to find your API Key, and how to authenticate your SQL API requests, view the [SQL API authentication](/cartodb-platform/sql-api/authentication/) guide.

## Errors

Errors are described in the response of the request. An example is as follows:

```json
{
  error: [
    "The api_key must be provided"
  ]
}
```

Since the Data Services API is used on top of the CartoDB SQL API, you can refer to the [Making calls to the SQL API](/cartodb-platform/sql-api/making-calls/) documentation for help debugging your SQL errors.

If the requested information is not in the CartoDB geocoding database, or if CartoDB is unable to recognize your input and match it with a result, the geocoding function returns `null` as a result.

## Limits

Usage of the Data Services API is subject to the CartoDB SQL API limits, stated in our [Terms of Service](https://cartodb.com/terms/#excessive).

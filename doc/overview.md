# Overview

By using CartoDB libraries and the SQL API, you can apply location data services to your maps with select functions. These functions are integrated with a number of internal and external services, enabling you to programatically customize subsets of data for your visualizations. For example, you can transform an address to a geometry with [geocoding functions](http://docs.cartodb.com/cartodb-platform/dataservices-api/geocoding-functions/#geocoding-functions). You can also use [isoline functions](http://docs.cartodb.com/cartodb-platform/dataservices-api/isoline-functions/#isoline-functions) to calculate the travel distance for a defined area. These features are useful for geospatial analysis and the results can be saved, and stored, for additional location data service operations.

**Note:** Based on your account plan, some of these data services are subject to different [quota limitations](http://docs.cartodb.com/cartodb-platform/dataservices-api/quota-information/#quota-information).

_The Data Services API is collaborating with Mapzen, and several other geospatial service providers, in order to supply the best location data services from within our CartoDB Platform._

## Data Services Integration

By using the SQL API to query the Data Services API functions, you can manage specific operations and the corresponding geometries (a `polygon` or a `point`), according to the input information.

The Data Services API decouples the geocoding and isoline services from the CartoDB Editor. The API allows you to geocode data (from single rows, complete datasets, or simple inputs) and to perform trade areas analysis (computing isodistances or isochrones) programatically, through authenticated requests.

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/).

**Note:** The Data Services API [geocoding functions](http://docs.cartodb.com/cartodb-platform/dataservices-api/geocoding-functions/#geocoding-functions) return different types of geometries (points or polygons) as result of different geocoding processes. The CartoDB Platform does not support multi-geometry layers or datasets, therefore you must confirm that you are using consistent geometry types inside a table, to avoid future conflicts in your map visualization.

## Authentication

All requests performed to the CartoDB Data Services API must be authenticated with the user API Key. For more information about where to find your API Key, and how to authenticate your SQL API requests, view the [SQL API authentication](/cartodb-platform/sql-api/authentication/) documentation.

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

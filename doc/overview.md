# Overview

By using CARTO libraries and the SQL API, you can apply location data services to your maps with unique data services functions. These functions are integrated with a number of internal and external services, enabling you to programatically customize subsets of data for your visualizations. These features are useful for geospatial analysis and the results can be saved, and stored, for additional location data service operations.

**Note:** Based on your account plan, some of these data services are subject to different [quota limitations](https://carto.com/docs/carto-engine/dataservices-api/quota-information/#quota-information).

_The Data Services API is collaborating with [Mapzen](https://mapzen.com/), and several other geospatial service providers, in order to supply the best location data services from within our CARTO Engine._

## Data Services Integration

By using the SQL API to query the Data Services API functions, you can manage specific operations and the corresponding geometries (a `polygon` or a `point`), according to the input information.

The Data Services API decouples the geocoding and isoline services from the CARTO Editor. The API allows you to geocode data (from single rows, complete datasets, or simple inputs) and to perform trade areas analysis (computing isodistances or isochrones) programatically, through authenticated requests.

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/).

**Note:** The Data Services API [geocoding functions](https://carto.com/docs/carto-engine/dataservices-api/geocoding-functions/#geocoding-functions) return different types of geometries (points or polygons) as result of different geocoding processes. The CARTO Engine does not support multi-geometry layers or datasets, therefore you must confirm that you are using consistent geometry types inside a table, to avoid future conflicts in your map visualization.

### Best Practices

_Be mindful of the following usage notes when using the Data Services functions with the SQL API:_

It is discouraged to use the SELECT operation with the Data Services API functions in your map layers, as these type of queries consume quota when rendering tiles for your live map views. It may also result in sync performance issues, due to executing multiple requests to the API each time your map is viewed. See details about [Quota Consumption](https://carto.com/docs/carto-engine/dataservices-api/quota-information/#quota-consumption).

The Data Services API is **recommended** to be used with INSERT or UPDATE operations, for applying location data to your tables. While SELECT (retrieve) is standard for SQL API requests, be mindful of quota consumption and use INSERT (to insert a new record) or UPDATE (to update an existing record), for best practices.

## Authentication

All requests performed to the CARTO Data Services API must be authenticated with the user API Key. For more information about where to find your API Key, and how to authenticate your SQL API requests, view the [SQL API authentication](/carto-engine/sql-api/authentication/) documentation.

## Errors

Errors are described in the response of the request. An example is as follows:

```json
{
  error: [
    "The api_key must be provided"
  ]
}
```

Since the Data Services API is used on top of the CARTO SQL API, you can refer to the [Making calls to the SQL API](https://carto.com/docs/carto-engine/sql-api/making-calls/) documentation for help debugging your SQL errors.

If the requested information is not in the CARTO geocoding database, or if CARTO is unable to recognize your input and match it with a result, the geocoding function returns `null` as a result.

## Limits

Usage of the Data Services API is subject to the CARTO SQL API limits, stated in our [Terms of Service](https://carto.com/terms/#excessive).

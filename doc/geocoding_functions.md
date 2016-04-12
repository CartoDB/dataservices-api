# Geocoding Functions

The [geocoder](https://cartodb.com/data/geocoder-api/) functions allow you to match your data with geometries on your map. This geocoding service can be used programatically to geocode datasets via the CartoDB SQL API. It is fed from _Open Data_ and it serves geometries for countries, provinces, states, cities, postal codes, IP addresses and street addresses. CartoDB provides functions for several different categories of geocoding through the Data Services API.

	**This service is subject to quota limitations, and extra fees may apply**. View the [Quota Information](http://docs.cartodb.com/cartodb-platform/dataservices-api/quota-information/) section for details, and recommendations, about to quota consumption.

Here is an example of how to geocode a single country:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_geocode_admin0_polygon('USA')&api_key={api_key}
```

In order to geocode an existent CartoDB dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Geocoding API. For example, if the column where you are storing the country names for each one of our rows is called `country_column`, run the following statement in order to geocode the dataset:

```bash
https://{username}.cartodb.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocode_admin0_
```

The following geocoding functions are available, grouped by categories.

## Country Geocoder

This function geocodes country names by transforming them into country border geometries. It recognizes the names of the different countries either by different synonyms (such as their English name or their endonym), or by ISO (ISO2 or ISO3) codes.

### cdb_geocode_admin0_polygon(_country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`country_name` | `text` | Name of the country

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin0_polygon('France')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin0_polygon({country_column})
```


## Level-1 Administrative Regions Geocoder

This function geocodes the [Level 1](https://en.wikipedia.org/wiki/Table_of_administrative_divisions_by_country), or [NUTS-1](https://en.wikipedia.org/wiki/NUTS_1_statistical_regions_of_England), administrative divisions (or units) of countries and transforms them into polygon geometries. For example, a "state" in the United States, a region in France, or an autonomous community in Spain.

### cdb_geocode_admin1_polygon(_admin1_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin1_polygon('Alicante')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column})
```

### cdb_geocode_admin1_polygon(_admin1_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`admin1_name` | `text` | Name of the province/state
`country_name` | `text` | Name of the country in which the province/state is located

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_admin1_polygon('Alicante', 'Spain')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_admin1_polygon({province_column}, {country_column})
```


## City Geocoder

This fuction geocodes the names of cities and transforms them to a point geometries. It is recommended to use geocoding functions that require more parameters — in order for the result to be as accurate as possible when several cities share their name. If there are duplicate results for a city name, the city name with the highest population will be returned.

### cdb_geocode_namedplace_point(_city_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('Barcelona')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column})
```

### cdb_geocode_namedplace_point(_city_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`country_name` | `text` | Name of the country in which the city is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('Barcelona', 'Spain')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, 'Spain')
```

### cdb_geocode_namedplace_point(_city_name text, admin1_name text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`city_name` | `text` | Name of the city
`admin1_name` | `text` | Name of the province/state in which the city is located
`country_name` | `text` | Name of the country in which the city is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_namedplace_point('New York', 'New York', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_namedplace_point({city_column}, {province_column}, 'USA')
```

## Postal Code Geocoder

This function geocodes postal codes and country names and transforms them to points or polygon geometries. The postal code polygon geocoder covers the United States, France, Australia and Canada; a request for a different country will return an empty response.

### cdb_geocode_postalcode_polygon(_postal_code text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

#### Returns

Geometry (polygon, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_postalcode_polygon('11211', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_polygon({postal_code_column}, 'USA')
```

**Note:** For the USA, US Census ZCTAs are considered.

### cdb_geocode_postalcode_point(_code text, country_name text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`postal_code` | `text` | Postal code
`country_name` | `text` | Name of the country in which the postal code is located

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_postalcode_point('11211', 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_postalcode_point({postal_code_column}, 'USA')
```

## IP Addresses Geocoder

This function geocodes both IPv4, and IPv6, IP addresses and transforms them into point geometries. This is useful if you are analyzing location based data, based on a set of user's IP addresses.

### cdb_geocode_ipaddress_point(_ip_address text_)

#### Arguments

Name | Type | Description
--- | --- | ---
`ip_address` | `text` | Postal code
`country_name` | `text` | IPv4 or IPv6 address

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

```bash
SELECT cdb_geocode_ipaddress_point('102.23.34.1')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_ipaddress_point('102.23.34.1')
```

## Street-Level Geocoder

This function geocodes street addresses and transforms them into point geometries. CartoDB uses several different service providers for street-level geocoding, depending on your platform. If you access CartoDB on a Google Cloud Platform, [Google Maps geocoding](https://developers.google.com/maps/documentation/geocoding/intro) is applied. All other platform users are provided with [HERE geocoding services](https://developer.here.com/rest-apis/documentation/geocoder/topics/quick-start.html). Additional service providers will implemented in the future.

**This service is subject to quota limitations, and extra fees may apply**. View the [Quota information](http://docs.cartodb.com/cartodb-platform/dataservices-api/quota-information/) for details and recommendations about quota consumption.

### cdb_geocode_street_point(_search_text text, [city text], [state text], [country text]_)

#### Arguments

Name | Type | Description
--- | --- | --- | ---
`searchtext` | `text` | searchtext contains free-form text containing address elements. You can specify the searchtext parameter by itself, or with other parameters, to narrow your search. For example, you can specify the state or country parameters, along with a free-form address in the searchtext field.
`city` | `text` | (Optional) Name of the city.
`state` | `text` | (Optional) Name of the state.
`country` | `text` | (Optional) Name of the country.

#### Returns

Geometry (point, EPSG 4326) or null

#### Example

##### Select

Using SELECT for geocoding functions

```bash
SELECT cdb_geocode_street_point('651 Lombard Street, San Francisco, California, United States')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco', 'California')
SELECT cdb_geocode_street_point('651 Lombard Street', 'San Francisco', 'California', 'United States')
SELECT cdb_geocode_street_point('651 Lombard Street San Francisco California', NULL, NULL, 'USA')
```

##### Update

```bash
UPDATE {tablename} SET the_geom = cdb_geocode_street_point({street_name_column})
```

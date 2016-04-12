# Geocoding Functions

The geocoder functions allow you to match your data with geometries on your map. This geocoding service can be used programatically to geocode datasets via the CartoDB SQL API. It is fed from _Open Data_ and it serves geometries for countries, provinces, states, cities, postal codes, IP addresses and street addresses. Geocoding functions through CartoDB are available by requesting a single function in the Data Services API.

**This service is subject to quota limitations, and extra fees may apply**. View the [Quota Information](http://docs.cartodb.com/cartodb-platform/dataservices-api/quota-information/) section for details, and recommendations, about to quota consumption.


## Quickstart

Here is an example of how to geocode a single country:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_geocode_admin0_polygon('USA')&api_key={api_key}
```

In order to geocode an existent CartoDB dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Geocoding API. For example, if the column where you are storing the country names for each one of our rows is called `country_column`, run the following statement in order to geocode the dataset:

```bash
https://{username}.cartodb.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocode_admin0_
```

The following geocoding functions are available, grouped by categories.

## Country geocoder

This function provides a country geocoding service. It recognizes the names of the different countries from different synonyms, such as their English name, their endonym, or their ISO2 or ISO3 codes.

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


## Level-1 Administrative regions geocoder

The following functions provide a geocoding service for administrative regions of level 1 (or NUTS-1) such as states for the United States, regions in France or autonomous communities in Spain.

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


## City geocoder

The following functions provide a city geocoder service. It is recommended to use the more specific geocoding function -- the one that requires more parameters — in order for the result to be as accurate as possible when several cities share their name.

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

## Postal codes geocoder

The following functions provide a postal code geocoding service that can be used to obtain points or polygon results. The postal code polygon geocoder covers the United States, France, Australia and Canada; a request for a different country will return an empty response.

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

## IP addresses geocoder

This function provides an IP address geocoding service, for both IPv4 and IPv6 addresses.

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

## Street-level geocoder

This function provides a street-level geocoding service. This service uses the street level geocoder defined for the user.

**This service is subject to quota limitations, and extra fees may apply**. Please view our [terms and conditions](https://cartodb.com/terms/) and check out the [Quota information section](http://docs.cartodb.com/cartodb-platform/dataservices-api/quota-information/) for details and recommendations related with quota usage.

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
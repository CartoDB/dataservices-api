## Geocoder API

### Overview
The CartoDB Geocoder API allows you to geocode your data by converting your data into geometries in your map. This geocoding service can be used programatically to geocode datasets via the CartoDB SQL API. It is fed from _Open Data_ and it serves geometries for countries, provinces, states, cities, postal codes and IP addresses.

### Quickstart
If you are using the set of APIs and libraries that CartoDB offers and you are handling your data with the SQL API, you can make your data visible in your maps by geocoding the dataset programatically.

Here's an example of how to geocode a single country:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT cdb_geocoder_client.geocode_admin0_polygon('USA')&api_key={Your API key}
```

In order to geocode an existent CartoDB dataset, an SQL UPDATE statement must be used to populate the geometry column in the dataset with the results of the Geocoding API. If the column in which we are storing the country names for each one of our rows is called `country_column`, we can run the following statement in order to geocode the dataset:

```bash
https://{username}.cartodb.com/api/v2/sql?q=UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_admin0_polygon({country_column})&api_key={Your API key}
```

Notice that you can make use of Postgres or PostGIS functions in your Geocoder API requests, as the result of it will be a geometry that can be handled by the system. As an example, if you need to retrieve the centroid of a specific country, you can wrap the resulting geometry from the Geocoder API inside the PostGIS `ST_Centroid` function:

```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT ST_Centroid(cdb_geocoder_client.geocode_admin0_polygon('USA'))&api_key={Your API key}
```

### General concepts
The Geocoder API offers geocoding services on top of the CartoDB SQL API by means of a set of geocoding functions. Each one of these functions is oriented to one kind of geocoding operation and it will return the corresponding geometry (a `polygon` or a `point`) according to the input information.

The Geocoder API decouples the geocoding service from the CartoDB Editor, and allows to geocode data (being single rows, complete datasets or simple inputs) programatically through authenticated requests.

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/).

The Geocoder API can return different types of geometries (points or polygons) as result of different geocoding processes. The CartoDB platform does not support multigeometry layers or datasets, therefore the final users of this Geocoder API must check that they are using consistent geometry types inside a table to avoid further conflicts in the map visualization.

#### Authentication
All requests performed to the CartoDB Geocoder API must be authenticated with the user API Key. For more information about where to find your API Key and how to authenticate your SQL API requests, check the [SQL API authentication(http://docs.cartodb.com/cartodb-platform/sql-api/authentication/) guide.

#### Errors
Errors will be described in the response of the geocoder request. An example is as follows:

  ```json
  {
     error: [
          "function geocode_countries(text) does not exist"
     ]
  }
  ```

Due to the fact that the Geocoder API is used on top of the CartoDB SQL API you can check the [Making calls to the SQL API](http://docs.cartodb.com/cartodb-platform/sql-api/making-calls/) section to help you debug your SQL errors.

If the requested information is not in the CartoDB geocoding database, or if CartoDB is unable of recognizing your input and matching it with a result, the geocoding function will return `null` as a result. 

#### Limits
The usage of the Geocoder API is subject to the CartoDB SQL API limits stated in our [Terms of Service](https://cartodb.com/terms/#excessive).

### Reference
#### Geocoding functions
The available geocoding functions are listed below, grouped by categories.

##### Country geocoder
This function provides a country geocoding service. It recognizes the names of the different countries from different synonyms, such as their English name, their endonym, or their ISO2 or ISO3 codes. 

###### geocode_admin0_polygon

  * `geocode_admin0_polygon(country_name text)`
     * **Parameters**: 
        * Name: `country_name` Type: `text` Description: Name of the country
     * **Return type:** Geometry (polygon)
     * **Usage example:**
     
       SELECT
       `````
       SELECT cdb_geocoder_client.geocode_admin0_polygon('France')
       `````

       UPDATE
       `````
       UPDATE {tablename} SET {the_geom} = cdb_geocoder_client.geocode_admin0_polygon({country_column})
       `````

#### Level-1 Administrative regions geocoder
The following functions provide a geocoding service for administrative regions of level 1 (or NUTS-1) such as states for the United States, regions in France or autonomous communities in Spain.

###### geocode_admin1_polygon
* Functions: 
  * `geocode_admin1_polygon(admin1_name text)`
    * **Parameters**: 
        * Name: `admin1_name` Type: `text` Description: Name of the province/state
    * **Return type:** Geometry (polygon)
    * **Usage example:**
    
      SELECT
      `````
      SELECT cdb_geocoder_client.geocode_admin1_polygon('Alicante')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_admin1_polygon({province_column})
      `````

  *  `geocode_admin1_polygon(admin1_name text, country_name text)`
    * **Parameters**: 
        * Name: `admin1_name` Type: `text` Description: Name of the province/state
        * Name: `country_name` Type: `text` Description: Name of the country in which the province/state is located
    * **Return type:** `polygon`
    * **Usage example:**
     
     SELECT
      `````
      SELECT cdb_geocoder_client.geocode_admin1_polygon('Alicante', 'Spain')
      `````

     UPDATE
     `````
     UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_admin1_polygon({province_column}, {country_column})
     `````

#### City geocoder
The following functions provide a city geocoder service. It is recommended to use the more specific geocoding function -- the one that requires more parameters -- in order for the result to be as accurate as possible when several cities share their name.

##### geocode_namedplace_point
* Functions:
  *  `geocode_namedplace_point(city_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
    * **Return type:** Geometry (point)
    * **Usage example:**
    
      SELECT
      `````
      SELECT cdb_geocoder_client.geocode_namedplace_point('Barcelona')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_namedplace_point({city_column})
      `````

  *  `geocode_namedplace_point(city_name text, country_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
        * Name: `country_name` Type: `text` Description: Name of the country in which the city is located
    * **Return type:** Geometry (point)
    * **Usage example:**
    
      SELECT
      `````
      SELECT cdb_geocoder_client.geocode_namedplace_point('Barcelona', 'Spain')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_namedplace_point({city_column}, 'Spain')
      `````
      
  *  `geocode_namedplace_point(city_name text, admin1_name text, country_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
        * Name: `admin1_name` Type: `text` Description: Name of the province/state in which the city is located
        * Name: `country_name` Type: `text` Description: Name of the country in which the city is located
    * **Return type:** Geometry (point)
    * **Usage example:**
      `````
      SELECT cdb_geocoder_client.geocode_namedplace_point('New York', 'New York', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_namedplace_point({city_column}, {province_column}, 'Spain')
      `````
      

#### Postal codes geocoder
The following functions provide a postal code geocoding service that can be used to obtain points or polygon results. The postal code polygon geocoder covers the United States, France, Australia and Canada; a request for a different country will return an empty response.

##### geocode_postalcode_polygon
* Functions:
  * `geocode_postalcode_polygon(postal_code text, country_name text)`
    * **Parameters**: 
        * Name: `postal_code` Type: `text` Description: Postal code
        * Name: `country_name` Type: `text` Description: Name of the country in which the postal code is located
    * **Return type:** Geometry (polygon)
    * **Usage example:**
        `````
      SELECT cdb_geocoder_client.geocode_postalcode_polygon('11211', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_postalcode_polygon({postal_code_column}, 'Spain')
      `````

** Note: For the USA, US Census ZCTAs are considered.

##### geocode_postalcode_point
* Functions:
  * `geocode_postalcode_point(code text, country_name text)`
    * **Parameters**: 
        * Name: `postal_code` Type: `text` Description: Postal code
        * Name: `country_name` Type: `text` Description: Name of the country in which the postal code is located
    * **Return type:** Geometry (point)
    * **Usage example:**
        `````
      SELECT cdb_geocoder_client.geocode_postalcode_point('11211', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_postalcode_point({postal_code_column}, 'United States')
      `````

#### IP addresses Geocoder
This function provides an IP address geocoding service, for both IPv4 and IPv6 addresses.

##### geocode_ipaddress_point
* Functions:
  * `geocode_ipaddress_point(ip_address text)`
    * **Parameters**: 
        * Name: `ip_address` Type: `text` Description: IPv4 or IPv6 address
    * **Return type:** Geometry (point)
    * **Usage example:**
        `````
      SELECT cdb_geocoder_client.geocode_ipaddress_point('102.23.34.1')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = cdb_geocoder_client.geocode_ipaddress_point('102.23.34.1')
      `````








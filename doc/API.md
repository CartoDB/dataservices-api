## Geocoder API

### Overview
**WIP**
### Quickstart



### General concepts
The Geocoder API offers geocoding services on top of the CartoDB SQL API by means of a set of geocoding functions. Each one of these functions is oriented to one kind of geocoding operation and it will return the corresponding geometry (a `polygon` or a `point`) according to the input information.

The Geocoder API decouples the geocoding service from the CartoDB Editor, and allows to geocode data (being single rows, complete datasets or simple inputs) programatically. 

The geometries provided by this API are projected in the projection [WGS 84 SRID 4326](http://spatialreference.org/ref/epsg/wgs-84/). 

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

#### Pre/post conditions
**WIP**

#### Possible side-effects
The Geocoder API can return different types of geometries as result of different geocoding processes. The CartoDB platform does not support multigeometry layers or datasets, therefore the final users of this Geocoder API must check that they are using consistent geometry types inside a table to avoid further conflicts in the map visualization.

### Reference
**WIP**
#### Geocoding functions
**WIP**
##### Country geocoder
This function provides a country geocoding service. It recognizes the names of the different countries from different synonyms, such as their English name, their endonym, or their ISO2 or ISO3 codes. 

###### geocode_admin0_polygon

  * `geocode_admin0_polygon(country_name text)`
     * **Parameters**: 
        * Name: `country_name` Type: `text` Description: Name of the country
     * **Return type:** `polygon`
     * **Usage example:**
     
       SELECT
       `````
       SELECT geocode_admin0_polygon('France')
       `````

       UPDATE
       `````
       UPDATE {tablename} SET {the_geom} = geocode_admin0_polygon({country_column})
       `````

#### Level-1 Administrative regions geocoder
The following functions provide a geocoding service for administrative regions of level 1 (or NUTS-1) such as states for the United States, regions in France or autonomous communities in Spain.

###### geocode_admin1_polygon
* Functions: 
  * `geocode_admin1_polygon(admin1_name text)`
    * **Parameters**: 
        * Name: `admin1_name` Type: `text` Description: Name of the province/state
    * **Return type:** `polygon`
    * **Usage example:**
    
      SELECT
      `````
      SELECT geocode_admin1_polygon('Alicante')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_admin1_polygon({province_column})
      `````

  *  `geocode_admin1_polygon(admin1_name text, country_name text)`
    * **Parameters**: 
        * Name: `admin1_name` Type: `text` Description: Name of the province/state
        * Name: `country_name` Type: `text` Description: Name of the country in which the province/state is located
    * **Return type:** `polygon`
    * **Usage example:**
     
     SELECT
      `````
      SELECT geocode_admin1_polygon('Alicante', 'Spain')
      `````

     UPDATE
     `````
     UPDATE {tablename} SET the_geom = geocode_admin1_polygon({province_column}, {country_column})
     `````

#### City geocoder
The following functions provide a city geocoder service. It is recommended to use the more specific geocoding function -- the one that requires more parameters -- in order for the result to be as accurate as possible when several cities share their name.

##### geocode_namedplace_point
* Functions:
  *  `geocode_namedplace_point(city_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
    * **Return type:** `point`
    * **Usage example:**
    
      SELECT
      `````
      SELECT geocode_namedplace_point('Barcelona')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_namedplace_point({city_column})
      `````

  *  `geocode_namedplace_point(city_name text, country_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
        * Name: `country_name` Type: `text` Description: Name of the country in which the city is located
    * **Return type:** `point`
    * **Usage example:**
    
      SELECT
      `````
      SELECT geocode_namedplace_point('Barcelona', 'Spain')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_namedplace_point({city_column}, 'Spain')
      `````
      
  *  `geocode_namedplace_point(city_name text, admin1_name text, country_name text)`
    * **Parameters**: 
        * Name: `city_name` Type: `text` Description: Name of the city
        * Name: `admin1_name` Type: `text` Description: Name of the province/state in which the city is located
        * Name: `country_name` Type: `text` Description: Name of the country in which the city is located
    * **Return type:** `point`
    * **Usage example:**
      `````
      SELECT geocode_namedplace_point('New York', 'New York', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_namedplace_point({city_column}, {province_column}, 'Spain')
      `````
      

#### Postal codes geocoder
The following functions provide a postal code geocoding service that can be used to obtain points or polygon results. The postal code polygon geocoder covers the United States, France, Australia and Canada.

##### geocode_postalcode_polygon
* Functions:
  * `geocode_postalcode_polygon(postal_code text, country_name text)`
    * **Parameters**: 
        * Name: `postal_code` Type: `text` Description: Postal code
        * Name: `country_name` Type: `text` Description: Name of the country in which the postal code is located
    * **Return type:** `polygon`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_polygon('11211', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_postalcode_polygon({postal_code_column}, 'Spain')
      `````

** Note: For the USA, US Census ZCTAs are considered.

##### geocode_postalcode_point
* Functions:
  * `geocode_postalcode_point(code text, country_name text)`
    * **Parameters**: 
        * Name: `postal_code` Type: `text` Description: Postal code
        * Name: `country_name` Type: `text` Description: Name of the country in which the postal code is located
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_postalcode_point('11211', 'USA')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_postalcode_point({postal_code_column}, 'United States')
      `````

#### IP addresses Geocoder
This function provides an IP address geocoding service, both for IPv4 and IPv6 addresses.

##### geocode_ipaddress_point
* Functions:
  * `geocode_ipaddress_point(ip_address text)`
    * **Parameters**: 
        * Name: `ip_address` Type: `text` Description: IPv4 or IPv6 address
    * **Return type:** `point`
    * **Usage example:**
        `````
      SELECT geocode_ipaddress_point('102.23.34.1')
      `````

      UPDATE
      `````
      UPDATE {tablename} SET the_geom = geocode_ipaddress_point('102.23.34.1')
      `````








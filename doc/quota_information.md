# Quota Information

**Based on your account plan, some of the Data Services API functions are subject to quota limitations and extra fees may apply.** View our [terms and conditions](https://carto.com/terms/), or [contact us](mailto:sales@carto.com) for details about which functions require service credits to your account.

## Quota Consumption

Quota consumption is calculated based on the number of request made for each function. Be mindful of the following usage recommendations when using the Data Services API functions:

* One credit per function call will be consumed. The results are not cached. If the query is applied to a _N_ rows dataset, then _N_ credits are consumed
* Avoid running dynamic queries to these functions in your maps. This can result in credit consumption per map view. 

  **Note:** Queries to the Data Services API, and any of its functions in your maps, may be forbidden in the future

* It is advised to store results of these queries into your datasets, and refresh them as needed. This ensure more control of quota credits for your account


## Quota information functions

Two functions are available to obtain information about available services quotas. 

## cdb_service_quota_info()

Returns information about per-service quotas (available and used) for the account.

#### Returns

This function returns a set of service quota information records, one per service.

Name            | Type      | Description
--------------- | --------- | ------------
`service`       | `text`    | Type of service.
`monthly_quota` | `numeric` | Quota available to the user (number of calls) per monthly period.
`used_quota`    | `numeric` | Quota used by the user in the present period.
`soft_limit`    | `boolean` | True if the user has *soft-limit* quota
`provider`      | `text`    | Service provider for this type of service

Service types:

* `'isolines'` [Isoline/Isochrones (isochrone/isodistance lines) service](https://carto.com/docs/carto-engine/dataservices-api/isoline_functions/)
* `'hires_geocoder'` [Street level geocoding](https://carto.com/docs/carto-engine/dataservices-api/geocoding-functions#street-level-geocoder)
* `'routing'` [Routing functions](https://carto.com/docs/carto-engine/dataservices-api/routing_functions/)
* `'observatory'` Data Observatory services ([demographic](https://carto.com/docs/carto-engine/dataservices-api/demographic_functions/) and [segmentation](https://carto.com/docs/carto-engine/dataservices-api/segmentation_functions/) functions)

Notes:

Users who have *soft-quota* activated never run out of quota, but they may incurr into extra
expenses when the regular quota is exceeded.

A zero value of `monthly_quota` indicates that the service has not been activated for the user.

#### Example

```sql
SELECT * FROM cdb_service_quota_info();
```

Result:

```
    service     | monthly_quota | used_quota | soft_limit |     provider
----------------+---------------+------------+------------+------------------
 isolines       |           100 |          0 | f          | mapzen
 hires_geocoder |           100 |          0 | f          | mapzen
 routing        |            50 |          0 | f          | mapzen
 observatory    |             0 |          0 | f          | data observatory
(4 rows)

```

In this case we notice the user has no access to the observatory services, 
all quotas are *hard-limited* (no soft limits), and no quota has been used 
in the present period.

## cdb_enough_quota(service text ,input_size numeric)

This function is useful to check if enough quota is available for completing a job.

This is specially relevant if a number of service calls are to be performed inside a transaction:
if any of the calls fails due to exceeded quota the transaction will be rolled back, resulting
in some quota being consumed but no saved results from the services consumed.

In the case of of calling repeatedly quota-consuming functions (e.g. to geocode a whole table) it is 
extremely important to first check if enough quota is available to complete the job using
this function.

#### Arguments

Name         | Type      | Description
------------ | --------- | -----------
`service`    | `text`    | Service to check; see the list of valid services above
`input_size` | `numeric` | Number of service calls required, i.e. size of the input to be processed

#### Returns

The result is a *boolean* value. A *true* value (`'t'`) indicates that the available quota
for the service is enough for the input size requested. A *false* value (`'f'`) indicates
insufficient quota.

#### Example

Imagine you wish to geocode a table named 
To check if you have enogh quota is available and avoiding ending with a partially

First you should find out how many records you need to geocode:

```sql
SELECT COUNT(*) FROM {tablename} WHERE {street_name_column} IS NOT NULL;
```

Result: here's a sample result of 10000 records:

```
 count
-------
  10000
(1 row)
```

Now you can find out if there's enough quota to complete this job

```sql
SELECT cdb_enough_quota('hires_geocoder', {number_of_records});
```

The result should be similar to this:

```
 cdb_enough_quota
------------------
 t
```

If the result of this query is *true* (`'t'`) you can safely proceed; if you get
a *false* value (`'f'`) you should avoid the processing; use `cdb_service_quota_info` as explained
above to obtain further information.

Don't forget to apply any filtering conditions you've used to 
count the records (in our case `{street_name_column} IS NOT NULL`):


```sql
UPDATE {tablename} SET the_geom = cdb_geocode_street_point({street_name_column})
  WHERE {street_name_column} IS NOT NULL;
```

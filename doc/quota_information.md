# Quota Information

**Based on your account plan, some of the Data Services API functions are subject to quota limitations and extra fees may apply.** View our [terms and conditions](https://carto.com/terms/), or [contact us](mailto:sales@carto.com) for details about which functions require service credits to your account.

## Quota Consumption

Quota consumption is calculated based on the number of request made for each function. Be mindful of the following usage recommendations when using the Data Services API functions:

* One credit per function call will be consumed. The results are not cached. If the query is applied to a _N_ rows dataset, then _N_ credits are consumed
* Avoid running dynamic queries to these functions in your maps. This can result in credit consumption per map view. 

  **Note:** Queries to the Data Services API, and any of its functions in your maps, may be forbidden in the future

* It is advised to store results of these queries into your datasets, and refresh them as needed. This ensure more control of quota credits for your account


## Quota Information Functions

There are several SQL functions that you can run to obtain quota information about your services. 

## cdb_service_quota_info()

Returns information about per-service quotas (available and used) for the account.

#### Returns

This function returns a set of service quota information records, one per service.

Name            | Type      | Description
--------------- | --------- | ------------
`service`       | `text`    | Type of service.
`monthly_quota` | `numeric` | Quota available to the user (number of calls) per monthly period.
`used_quota`    | `numeric` | Quota used by the user in the present period.
`soft_limit`    | `boolean` | Set to `True`, if the user has *soft-limit* quota.
`provider`      | `text`    | Service provider for this type of service.

Service Types:

* `'isolines'` [Isoline/Isochrones (isochrone/isodistance lines) service](https://carto.com/docs/carto-engine/dataservices-api/isoline_functions/)
* `'hires_geocoder'` [Street level geocoding](https://carto.com/docs/carto-engine/dataservices-api/geocoding-functions#street-level-geocoder)
* `'routing'` [Routing functions](https://carto.com/docs/carto-engine/dataservices-api/routing_functions/)
* `'observatory'` Data Observatory services ([demographic](https://carto.com/docs/carto-engine/dataservices-api/demographic_functions/) and [segmentation](https://carto.com/docs/carto-engine/dataservices-api/segmentation_functions/) functions)

**Notes**

Users who have *soft-quota* activated never run out of quota, but they may incur extra
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

In this case, notice that the user has no access to the observatory services. All quotas are *hard-limited* (no soft limits), and no quota has been used in the present period.

## cdb_enough_quota(service text ,input_size numeric)

This function is useful to check if enough quota is available for completing a job.

This is specifically relevant if a number of service calls are to be performed inside a transaction. If any of the calls fails (due to exceeded quota), the transaction will be rolled back; resulting in partial quota consumption, but no saved results from the services consumed.

**Tip:** If you are requesting repeating quota-consuming functions (e.g. to geocode a whole table), it is extremely important to check if enough quota is available to complete the job _before_ applying this function.

Note that some services consume more than one credit per row/call. For example, isolines (with more than one range/track) consume (N rows x M ranges) credits; indicating that the input size should be N x M.

#### Arguments

Name         | Type      | Description
------------ | --------- | -----------
`service`    | `text`    | Service to check; see the list of valid services above.
`input_size` | `numeric` | Number of service calls required, i.e. size of the input to be processed.

#### Returns

The result is a *boolean* value. A *true* value (`'t'`) indicates that the available quota
for the service is enough for the input size requested. A *false* value (`'f'`) indicates
insufficient quota.

#### Example

Suppose you want to geocode a whole table. In order to check that you have enough quota, and avoid a "quota exhausted" exception, first find out how many records you need to geocode:

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

The result shows how much quota is needed to complete this job. In this case,
each call to `cdb_geocode_street_point` consumes one quota credit. This indicates that we need one credit per row to geocode the whole table.

```sql
SELECT cdb_enough_quota('hires_geocoder', {number_of_records});
```

The result is similar to the following:

```
 cdb_enough_quota
------------------
 t
```

If the result of this query is *true* (`'t'`), you can safely proceed. If a *false* value (`'f'`) is returned, you should avoid processing any more requests that consume quota. Apply the `cdb_service_quota_info` function to get more information about your services.

**Note:** Remember to apply any filtering conditions that you used to count the records (in this case, `{street_name_column} IS NOT NULL`):


```sql
UPDATE {tablename} SET the_geom = cdb_geocode_street_point({street_name_column})
  WHERE {street_name_column} IS NOT NULL;
```

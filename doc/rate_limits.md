# Rate limits

Services can be rate-limited. (currently only gecoding is limited)

The rate limits configuration can be established at server, organization or user levels, the latter having precedence over the earlier.

The default configuration (a null or empty configuration) doesn't impose any limits.

The configuration consist of a JSON object with two attributes:

* `period`: the rate-limiting period, in seconds.
* `limit`: the maximum number of request in the established period.

If a service request exceeds the configured rate limits
(i.e. if more than `limit` calls are performe in a fixed interval of
duration `period` seconds) the call will fail with an "Rate limit exceeded" error.

## Server-side interface

There's a server-side SQL interface to query or change the configuration.

### cdb_dataservices_server.cdb_service_get_rate_limit(username, orgname, service)

This function returns the rate limit configuration for a given user and service.

#### Returns

The result is a JSON object with the configuration (`period` and `limit` attributes as explained above).

### cdb_dataservices_server.cdb_service_set_user_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the user. This overrides any other configuration.

The configuration is provided as a JSON literal. To remove the user-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_server.cdb_service_set_org_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the organization.
This overrides server level configuration and is overriden by user configuration if present.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

### cdb_dataservices_server.cdb_service_set_server_rate_limit(username, orgname, service, rate_limit)

This function sets the default rate limit configuration for all users accesing the dataservices server. This is overriden by organization of user configuration.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

## Client-side interface

For convenience there's also a client-side interface (in the client dataservices-api extension), consisting
of public functions to get the current configuration and privileged functions to change it.

### Public functions

These functions are accesible to non-privileged roles, and should only be executed
using the role corresponding to a CARTO user, since that will determine the
user and organization to which the rate limits configuration applies.

### cdb_dataservices_client.cdb_service_get_rate_limit(service)

This function returns the rate limit configuration in effect for the specified service
and the user corresponding to the role which makes the calls. The effective configuration
may come from any of the configuration levels (server/organization/user); only the
existing configuration with most precedence is returned.

#### Returns

The result is a JSON object with the configuration (`period` and `limit` attributes as explained above).

#### Example:

```
SELECT cdb_dataservices_client.cdb_service_get_rate_limit('geocoding');

   cdb_service_get_rate_limit
---------------------------------
 {"limit": 1000, "period": 86400}
(1 row)
```


### Privileged (superuser) functions

Thes functions are not accessible by regular user roles, and the user and organization names must be provided as parameters.

### cdb_dataservices_client.cdb_service_set_user_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the user. This overrides any other configuration.

The configuration is provided as a JSON literal. To remove the user-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

#### Example

This will configure the geocoding service rate limit for  user  `myusername`, a non-organization user.
The limit will be set at 1000 requests per day. Since the user doesn't belong to any organization,
`NULL` will be passed to the organization argument; otherwise the name of the user's organization should
be provided.

```
SELECT cdb_dataservices_client.cdb_service_set_user_rate_limit(
    'myusername',
    NULL,
    'geocoding',
    '{"limit":1000,"period":86400}'
);

 cdb_service_set_user_rate_limit
---------------------------------

(1 row)
```

### cdb_dataservices_client.cdb_service_set_org_rate_limit(username, orgname, service, rate_limit)

This function sets the rate limit configuration for the organization.
This overrides server level configuration and is overriden by user configuration if present.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

#### Example

This will configure the geocoding service rate limit for the `myorg` organization.
The limit will be set at 100 requests per hour.
Note that even we're setting the default configuration for the whole organization,
the name of a user of the organization must be provided for technical reasons.

```
SELECT cdb_dataservices_client.cdb_service_set_org_rate_limit(
    'myorgadmin',
    'myorg',
    'geocoding',
    '{"limit":100,"period":3600}'
);


 cdb_service_set_org_rate_limit
---------------------------------

(1 row)
```

### cdb_dataservices_client.cdb_service_set_server_rate_limit(username, orgname, service, rate_limit)

This function sets the default rate limit configuration for all users accesing the dataservices server. This is overriden by organization of user configuration.

The configuration is provided as a JSON literal. To remove the organization-level configuration `NULL` should be passed as the `rate_limit`.

#### Returns

This functions doesn't return any value.

#### Example

This will configure the default geocoding service rate limit for all users
accesing the data-services server.
The limit will be set at 10000 requests per month.
Note that even we're setting the default configuration for the server,
the name of a user and the name of the corresponding organization (or NULL)
must be provided for technical reasons.

```
SELECT cdb_dataservices_client.cdb_service_set_server_rate_limit(
    'myorgadmin',
    'myorg',
    'geocoding',
    '{"limit":10000,"period":108000}'
);


 cdb_service_set_server_rate_limit
---------------------------------

(1 row)
```

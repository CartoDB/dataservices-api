# CARTO Data Services API
The CARTO Data Services SQL API

### Deploy instructions
Steps to deploy a new Data Services API version :

- Deploy new version of dataservices API to all servers
- Update the server user using: ALTER EXTENSION cdb_dataservices_server UPDATE TO '\<CURRENT_VERSION\>';
- Update the python dependencies if needed: **cartodb_geocoder** and **heremaps**
- Add the needed config in the `cdb_conf` table:
  - `redis_metadata_config` and `redis_metrics_conf`
    - `{"sentinel_host": "localhost", "sentinel_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}`
  - `heremaps_conf`
    - `{"app_id": "APP_ID", "app_code": "APP_CODE"}`
- Deploy the client to all the servers with the new version
- Deploy the editor with the new dataservices api version changed (https://github.com/CartoDB/cartodb/blob/master/app/models/user/db_service.rb#L18)
- Execute the rails task to update first the CartoDB team organizaton to test in production
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_organizations['team']`
- Check if all works perfectly for our team. If so, execute the rake tasks to update all the users and organizations:
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_organizations['', true]`
  - `RAILS_ENV=production bundle exec rake cartodb:db:configure_geocoder_extension_for_non_org_users['', true]`
- Freeze the generated SQL file for the version. Eg. cdb_dataservices_server--0.0.1.sql

### Local install instructions

- install data services geocoder extension

    ```
    git clone https://github.com/CartoDB/data-services.git
    cd data-services/geocoder/extension
    sudo make install
    ```

- install observatory extension

    ```
    git clone https://github.com/CartoDB/observatory-extension.git
    cd observatory
    sudo make install
    ```

- install server and client extensions

    ```
    # in dataservices-api repo root path:
    cd dataservices-api
    cd client && sudo make install
    cd -
    cd server/extension && sudo make install
    ```

- install python library

    ```
    # in data-services repo root path:
    cd server/lib/python/cartodb_services && sudo pip install . --upgrade
    ```

- install extensions in user database

    ```
    create extension cdb_geocoder;
    create extension plproxy;
    create extension observatory;
    create extension cdb_dataservices_server;
    create extension cdb_dataservices_client;
    ```


### Server configuration

Configuration for the different services must be stored in the server database using `CDB_Conf_SetConf()`.

#### Redis configuration

If sentinel is used:

```sql
SELECT CDB_Conf_SetConf(
    'redis_metadata_config',
    '{"sentinel_host": "localhost", "sentinel_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}'
);
SELECT CDB_Conf_SetConf(
    'redis_metrics_config',
    '{"sentinel_host": "localhost", "sentinel_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}'
);
```

If sentinel is not used:

```sql
SELECT CDB_Conf_SetConf(
    'redis_metadata_config',
    '{"redis_host": "localhost", "redis_port": 6379, "sentinel_master_id": "", "timeout": 0.1, "redis_db": 5}'
);
SELECT CDB_Conf_SetConf(
    'redis_metrics_config',
    '{"redis_host": "localhost", "redis_port": 6379, "sentinel_master_id": "", "timeout": 0.1, "redis_db": 5}'
);
```

#### Users/Organizations

```sql
SELECT CDB_Conf_SetConf(
    'user_config',
    '{"is_organization": false, "entity_name": "<YOUR_USERNAME>"}'
);
```

#### HERE configuration

```sql
SELECT CDB_Conf_SetConf(
    'heremaps_conf',
    '{"geocoder": {"app_id": "here_geocoder_app_id", "app_code": "here_geocoder_app_code", "geocoder_cost_per_hit": "1"}, "isolines" : {"app_id": "here_isolines_app_id", "app_code": "here_geocoder_app_code"}}'
);
```

#### Mapzen configuration

```sql
SELECT CDB_Conf_SetConf(
    'mapzen_conf',
    '{"routing": {"api_key": "valhalla_app_key", "monthly_quota": 999999}, "geocoder": {"api_key": "search_app_key", "monthly_quota": 999999}, "matrix": {"api_key": "[your_matrix_key]", "monthly_quota": 1500000}}'
);
```

#### Data Observatory

```sql
SELECT CDB_Conf_SetConf(
    'data_observatory_conf',
    '{"connection": {"whitelist": [], "production": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api", "staging": "host=localhost port=5432 dbname=dataservices_db user=geocoder_api"}}'
);
```

#### Logger

```sql
SELECT CDB_Conf_SetConf(
    'logger_conf',
    '{"geocoder_log_path": "/tmp/geocodings.log", [ "min_log_level": "[debug|info|warning|error]", "rollbar_api_key": "SERVER_SIDE_API_KEY", "log_file_path": "LOG_FILE_PATH"]}'
);
```

#### Environment

The execution environment (development/staging/production) affects rollbar messages and other details.
The production environment is used by default.

```sql
SELECT CDB_Conf_SetConf(
    'server_conf',
    '{"environment": "[development|staging|production]"}'
);
```
### Server optional configuration

External services (Mapzen, Here) can have optional configuration, which is only needed for using non-standard services, such as on-premise installations. We can add the service parameters to an existing configuration like this:

```
# Here geocoder
SELECT CDB_Conf_SetConf(
'heremaps_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('heremaps_conf')),
    '{geocoder, service}',
    '{"json_url":"https://geocoder.api.here.com/6.2/geocode.json","gen":9,"read_timeout":60,"connect_timeout":10,"max_retries":1}'
)::json
);

# Here isolines
SELECT CDB_Conf_SetConf(
'heremaps_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('heremaps_conf')),
    '{isolines, service}',
    '{"base_url":"https://isoline.route.api.here.com","isoline_path":"/routing/7.2/calculateisoline.json","read_timeout":60,"connect_timeout":10,"max_retries":1}'
)::json
);

# Mapzen geocoder
SELECT CDB_Conf_SetConf(
'mapzen_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('mapzen_conf')),
    '{geocoder, service}',
    '{"base_url":"https://search.mapzen.com/v1/search","read_timeout":60,"connect_timeout":10,"max_retries":1}'
)::json
);

# Mapzen isochrones
SELECT CDB_Conf_SetConf(
'mapzen_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('mapzen_conf')),
    '{isochrones, service}',
    '{"base_url":"https://matrix.mapzen.com/isochrone","read_timeout":60,"connect_timeout":10,"max_retries":1}'
)::json
);

# Mapzen isolines (matrix service)
SELECT CDB_Conf_SetConf(
'mapzen_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('mapzen_conf')),
    '{matrix, service}',
    '{"base_url":"https://matrix.mapzen.com/one_to_many","read_timeout":60,"connect_timeout":10}'
)::json
);

# Mapzen routing
SELECT CDB_Conf_SetConf(
'mapzen_conf',
jsonb_set(
    to_jsonb(CDB_Conf_GetConf('mapzen_conf')),
    '{routing, service}',
    '{"base_url":"https://valhalla.mapzen.com/route","read_timeout":60,"connect_timeout":10}'
)::json
);
```
### User database configuration

User (client) databases need also some configuration so that the client extension can access the server:
#### Users/Organizations

```sql
SELECT CDB_Conf_SetConf('user_config', '{"is_organization": false, "entity_name": "<YOUR_USERNAME>"}');
```

#### Dataservices server

The `geocoder_server_config` (the name is not accurate for historical reasons) entry points
to the dataservices server DB (you can use a specific database for the server or your same user's):

```sql
SELECT CDB_Conf_SetConf(
    'geocoder_server_config',
    '{ "connection_str": "host=localhost port=5432 dbname=<SERVER_DB_NAME> user=postgres"}'
);
```
#### Search path

The search path must be configured in order to be able to execute the functions without using the schema:

```sql
ALTER ROLE "<USER_ROLE>" SET search_path="$user", public, cartodb, cdb_dataservices_client;
```

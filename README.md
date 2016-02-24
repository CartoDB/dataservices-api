# geocoder-api
The CartoDB Geocoder SQL API (server and client FTM)

### Deploy instructions
Steps to deploy a new Geocoder API version :

- Deploy new version of dataservices API to all servers
- Update the server user using: ALTER EXTENSION cdb_dataservices_server UPDATE TO '<CURRENT_VERSION>';
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

- install data services extension 

    ```
    git clone git@github.com:CartoDB/data-services.git
    data-services/geocoder/extension
    sudo make install
    ```

- install server and client extensions
    
    ```
    cd client && sudo make install
    cd server && sudo make install
    ```

- install python library

    ```
    cd server/lib/python/cartodb_services && python setup.py install
    ```

- install extensions in user database

    ```
    create extension cdb_geocoder;
    create extension plproxy;
    create extension cdb_dataservices_server;
    create extension cdb_dataservices_client;
    ```

- add configuration for different services in user database


    ```
    # select CDB_Conf_SetConf('redis_metadata_config', '{"sentinel_host": "localhost", "sentinel_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}');
    # select CDB_Conf_SetConf('redis_metrics_config', '{"sentinel_host": "localhost", "sentinel_port": 26379, "sentinel_master_id": "mymaster", "timeout": 0.1, "redis_db": 5}');
    
    # select CDB_Conf_SetConf('heremaps_conf', '{"app_id": "APP_ID", "app_code": "APP_CODE"}');
    # select CDB_Conf_SetConf('user_config', '{"is_organization": false, "entity_name": "geocoder"}')
    ```

- congigure plproxy to point to the same user database (you could do in a different one)

    ```
     select CDB_Conf_SetConf('geocoder_server_config', '{ "connection_str": "host=localhost port=5432 dbname=cartodb_dev_user_accf0647-d942-4e37-b129-8287c117e687_db user=postgres"}');
    ```

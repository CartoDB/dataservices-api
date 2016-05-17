All the services from Dataservices API are subject to quota management: check, limit, etc.

There are three main fields in the quota management:

- **Quota**: Number of requests of this kind the user could make, eg. Number of street geocoding requests
- **Soft limit**: This flag enables the user to surpass their assigned quota. When this flag is activated, there is no quota check so the user could make all the requests that they want.
- **Block price**: Price for every 1000 requests


All the user/organization quota information is stored in the user metadata in Redis but managed by the CartoDB Rails app through the User/Organization models. Nevertheless you could change/read the Redis information through the following keys:

- `hgetall rails:users:username`
- `hgetall rails:orgs:orgname`

This whole information is managed by the CartoDB Rails App too so we could make a number of useful operations in order to know how many quota do you have, how many quota have you spent this month, and so on:

- How can I know the current quota, number of uses, etc for a user?

  You could use the following endpoint to know it: `https://<username>.cartodb.com/api/v1/users/<user_id>?api_key=<api_key>`
  In the result of this endpoint you can see blocks with all the information. Eg:
  ```json
"geocoding": {
    "quota": 1000,
    "block_price": 1500,
    "monthly_use": 743,
    "hard_limit": true
}
```

  Note: the remaining credits left can be computed as: `remaining_quota = quota - monthly_use`.

- How can I set a new quota for a user:

  This operation could be done through the rails console:
    - First you have to connect to the rails console: `bundle exec rails c`
    - Once in the console you have to get the target user/organization:
        - `u = User.find(username: '<username>')`
        - `o = Organization.find(name: '<orgname>')`
    - After we have the user/organization, we could change the quota or the hard limit flag for the desired service. I'm going to use geocoding as an example but it could be done with all the services:
        - ```
            u.geocoding_quota = 2000
            [u.soft_geocoding_limit = true|false]
            u.save
        ```
        - ```
            o.geocoding_quota = 2000
            o.save
        ```
    - This way the user now has 2000 requests as their current quota
    - We can only change the hard limit flag for users, not for organizations

- What services could we edit?:

  The following list numbers all the current services but this is a living list so it could keep growing in the future:

    - Geocoding: `geocoding_quota`, `soft_geocoding_limit`
    - Isolines: `here_isolines_quota`, `soft_here_isolines_limit`
    - Data observatory snapshot: `obs_snapshot_quota`, `soft_obs_snapshot_limit`
    - Data observatory general: `obs_general_quota`, `soft_obs_general_limit`

Contributing
---

The issue tracker is at [github.com/CartoDB/dataservices-api](https://github.com/CartoDB/dataservices-api).

We love pull requests from everyone, see [Contributing to Open Source on GitHub](https://guides.github.com/activities/contributing-to-open-source/#contributing).

## PostgreSQL
When adding or modifying PostgreSQL functions make sure that the
[VOLATILITY](https://www.postgresql.org/docs/current/static/xfunc-volatility.html) and [PARALLEL](https://www.postgresql.org/docs/9.6/static/parallel-safety.html) categories are updated accordingly.

Please mark public [client functions](client/sql) or [templates](client/renderer/templates)
as STABLE even if the internals are VOLATILE to allow the planner to cache
results inside a query. For example, in this query we need `cdb_geocode_admin1_polygon`
to be STABLE so it gets called only once (instead of once per row):
```sql
SELECT * japank WHERE NOT (the_geom && cdb_geocode_admin1_polygon('Madrid', 'Spain'));
```

As PARALLEL labels need to be stripped for incompatible PostgreSQL versions,
please use _PARALLEL SAFE/RESTRICTED/UNSAFE_ in uppercase so it's handled
automatically.



## Submitting Contributions

* You will need to sign a Contributor License Agreement (CLA) before making a submission. [Learn more here](https://carto.com/contributions).

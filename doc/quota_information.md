# Quota Information

**Based on your account plan, some of the Data Services API functions are subject to quota limitations and extra fees may apply.** View our [terms and conditions](https://cartodb.com/terms/), or [contact us](mailto:sales@cartodb.com) for details about which functions require service credits to your account.

## Quota Consumption

Quota consumption is calculated based on the number of request made for each function. Be mindful of the following usage recommendations when using the Data Services API functions:

* One credit per function call will be consumed. The results are not cached. If the query is applied to a _N_ rows dataset, then _N_ credits are consumed
* Avoid running dynamic queries to these functions in your maps. This can result in credit consumption per map view. **Note:** Queries to the Data Services API, and any of its functions in your maps, may be forbidden in the future
* It is advised to store results of these queries into your datasets, and refresh them as needed. This ensure more control of quota credits for your account

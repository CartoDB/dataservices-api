# Demographic Functions

The Demographic Snapshot API function enables you to collect demographic details around a point location. For example, you can take the coordinates of a bus stop and find the average population characteristics in that location. If you need help creating coordinates from addresses, see the [Geocoding Functions](/cartodb-platform/dataservices-api/geocoding-functions/) documentation.

_**Note:** The Demographic Snapshot API is currently only available for the United States._

## OBS_GetDemographicSnapshot( Point Geometry );

<<<<<<<<**PLEASE CONFIRM NAME, SPACING IN THE ACTUAL DATASERVICES API CODE APPEARS DIFFERENTLY FOR THIS FUNCTION?**>>>>>>>>

Fields returned include information about income, education, transportation, race, and more. Not all fields will have information for every coordinate queried.

### Arguments

Name | Description | Example Values
--- | --- | ---
username | The username of your CartoDB account where the Data Observatory has been enabled  | `username`
point geometry | A WKB point geometry. You can use the helper function, `CDB_LatLng` to quickly generate one from latitude and longitude | `CDB_LatLng(40.760410,-73.964242)`

### Returns

The Demographic Snapshot contains a broad subset of demographic measures in the Data Observatory. Over 80 measurements are returned by a single API request. 

[Click to expand](https://gist.github.com/ohasselblad/c9e59a6e8da35728d0d81dfed131ed17)

<<<<<<<<**HOW DO YOU WANT TO DISPLAY THIS INTERNAL CONTENT?**>>>>>>>>

Name | Type | Description
--- | --- | ---

[https://docs.google.com/spreadsheets/d/1U3Uajw_PsIy3_YgeujnJ7AiL2VREdT-ozdaulx07q2g/edit#gid=430723120](https://docs.google.com/spreadsheets/d/1U3Uajw_PsIy3_YgeujnJ7AiL2VREdT-ozdaulx07q2g/edit#gid=430723120)

<<<<<<<<**IS THIS THE SAME AS THE MEASURES_TABLE OPTIONS IN THE OBSERVATORY-EXTENSION GLOSSARY docs, OR SOMETHING DIFFERENT?**>>>>>>>>

### Examples

<<<<<<<<**THESE SHOULD BE WORKABLE EXAMPLES, WHY AREN'T WE USING {username}, LIKE OTHER API EXAMPLES?**>>>>>>>>

```html
https://{{username}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot({{point geometry}})
```

##### Get the Geographic Snapshot of a Demographic

__Get the Demographic Snapshot at Camp David__


```text
https://{username}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(39.648333, -77.465))
```

__Get the Demographic Snapshot in the Upper West Side__


```text
https://{username}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(40.80, -73.960))
```

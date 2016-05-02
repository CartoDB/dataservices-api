# Segmentation Functions

The Segmentation Snapshot API function enables you to determine the pre-calculated population segment for a location. For example, you can take the location of a store location and determine what classification of population exists around that location. If you need help creating coordinates from addresses, see the [Geocoding Functions](/cartodb-platform/dataservices-api/geocoding-functions/) documentation.

_**Note:** Segmentation is a method that divides a target market into subgroups based on shared common traits. Currently, CartoDB includes the segmentation profile defined in the Output Data: US_tract_clusters_new_, as detailed in the _[Understanding America's Neighborhoods Using Uncertain Data from the American Community Survey](http://www.tandfonline.com/doi/pdf/10.1080/00045608.2015.1052335) contextual approach. Subsequent releases will include additional segmentation profiles._

## OBS_GetSegmentationSnapshot( Point Geometry );

<<<<<<<<**PLEASE CONFIRM NAME, SPACING IN THE ACTUAL DATASERVICES API CODE APPEARS DIFFERENTLY FOR THIS FUNCTION?**>>>>>>>>

##### Geographic Scope

The Segmentation Snapshot API is available for the following countries:

* United States

<<<<<<<<**ARE THERE ANY MORE COUNTRIES SUPPORTED? OTHERWISE, I WILL MOVE THIS SECTION AS A NOTE INSTEAD**>>>>>>>>

### Arguments

Name | Type | Description | Example Values
--- | --- | --- | ---
account name | The name of your CartoDB account where the Data Observatory has been enabled  | `example_account`
point geometry | A WKB point geometry. You can use the helper function, `CDB_LatLng` to quickly generate one from latitude and longitude | `CDB_LatLng(40.760410,-73.964242)`

<<<<<<<<**IS ACCOUNT NAME DIFFERENT THAN THE USERNAME FROM THEIR ACCOUNT SETTINGS?**>>>>>>>>

### Returns

__todo__

Name | Type | Description
--- | --- | ---

__todo__

### Examples

<<<<<<<<**THESE SHOULD BE WORKABLE EXAMPLES, WHY AREN'T WE USING {username}, LIKE OTHER API EXAMPLES?**>>>>>>>>

```html
https://{{account name}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot({{point geometry}})
```

##### Get the Geographic Snapshot of a Segmentation

__Get the Segmentation Snapshot around the MGM Grand__


```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(36.10222, -115.169516))
```

__Get the Segmentation Snapshot at CartoDB's NYC HQ__


```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(40.704512, -73.936669))
```

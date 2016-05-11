# Segmentation Functions

The Segmentation Snapshot functions enable you to determine the pre-calculated population segment for a location. Segmentation is a method that divides a populations into subclassifications based on common traits. For example, you can take the a store location and determine what classification of population exists around that location. If you need help creating coordinates from addresses, see the [Geocoding Functions](/cartodb-platform/dataservices-api/geocoding-functions/) documentation.

_**Note:** The Segmentation Snapshot functions are only available for the United States. Our first release (May 18, 2016) is derived from Census 2010 variables. Our next release will be based on Census 2014 data. For the latest information, see the [Open Segments](https://github.com/CartoDB/open-segments) project repository._

## OBS_GetSegmentationSnapshot( Point Geometry );

### Arguments

Name | Type | Description | Example Values
--- | --- | --- | ---
username | The username of your CartoDB account where the Data Observatory has been enabled  | `example_account`
point geometry | A WKB point geometry. You can use the helper function, `CDB_LatLng` to quickly generate one from latitude and longitude | `CDB_LatLng(40.760410,-73.964242)`

### Returns

__todo__

Name | Type | Description
--- | --- | ---

__todo__

### Examples

```bash
https://{{username}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot({{point geometry}})
```

##### Get the Geographic Snapshot of a Segmentation

__Get the Segmentation Snapshot around the MGM Grand__


```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(36.10222, -115.169516))
```

__Get the Segmentation Snapshot at CartoDB's NYC HQ__


```bash
https://{username}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(40.704512, -73.936669))
```

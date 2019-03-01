## Segmentation Functions

The Segmentation Snapshot functions enable you to determine the pre-calculated population segment for a location. Segmentation is a method that divides a populations into subclassifications based on common traits. For example, you can take the a store location and determine what classification of population exists around that location. If you need help creating coordinates from addresses, see the [Geocoding Functions](https://carto.com/docs/carto-engine/dataservices-api/geocoding-functions/) documentation.

_**Note:** The Segmentation Snapshot functions are only available for the United States. Our first release (May 18, 2016) is derived from Census 2010 variables. Our next release will be based on Census 2014 data. For the latest information, see the [Open Segments](https://github.com/CartoDB/open-segments) project repository._

### OBS_GetSegmentSnapshot( Point Geometry )

#### Arguments

Name | Description | Example Values
--- |  --- | ---
point geometry | A point geometry. You can use the helper function, `CDB_LatLng` to quickly generate one from latitude and longitude | `CDB_LatLng(40.760410,-73.964242)`

#### Returns

The segmentation function returns two segment levels for the point you requests, the x10\_segment and x55\_segment. These segmentation levels contain different classifications of population within with each segment. The function also returns the quantile of a number of census variables. For example, if total_poulation is at 90% quantile level then this tract has a higher total population than 90% of the other tracts. 

Name | Type | Description
---- | ---- | -----------
x10\_segment | text | The demographic segment location at the 10 segment level, containing populations at high-levels, broken down into 10 broad categories
x55\_segment | text | The demographic segment location at the 55 segment level, containing more granular sub-levels to categorize the population

An example response appears as follows:

```json 
obs_getsegmentsnapshot: {
  "x10_segment": "Wealthy, urban without Kids",
  "x55_segment": "Wealthy city commuters",
  "us.census.acs.B01001001_quantile": "0.0180540540540541",
  "us.census.acs.B01001002_quantile": "0.0279864864864865",
  "us.census.acs.B01001026_quantile": "0.016527027027027",
  "us.census.acs.B01002001_quantile": "0.507297297297297",
  "us.census.acs.B03002003_quantile": "0.133162162162162",
  "us.census.acs.B03002004_quantile": "0.283743243243243",
  "us.census.acs.B03002006_quantile": "0.683945945945946",
  "us.census.acs.B03002012_quantile": "0.494594594594595",
  "us.census.acs.B05001006_quantile": "0.670972972972973",
  "us.census.acs.B08006001_quantile": "0.0607567567567568",
  "us.census.acs.B08006002_quantile": "0.0684324324324324",
  "us.census.acs.B08006008_quantile": "0.565135135135135",
  "us.census.acs.B08006009_quantile": "0.638081081081081",
  "us.census.acs.B08006011_quantile": "0",
  "us.census.acs.B08006015_quantile": "0.900932432432432",
  "us.census.acs.B08006017_quantile": "0.186648648648649",
  "us.census.acs.B09001001_quantile": "0.0193513513513514",
  "us.census.acs.B11001001_quantile": "0.0617972972972973",
  "us.census.acs.B14001001_quantile": "0.0179594594594595",
  "us.census.acs.B14001002_quantile": "0.0140405405405405",
  "us.census.acs.B14001005_quantile": "0",
  "us.census.acs.B14001006_quantile": "0",
  "us.census.acs.B14001007_quantile": "0",
  "us.census.acs.B14001008_quantile": "0.0609054054054054",
  "us.census.acs.B15003001_quantile": "0.0314594594594595",
  "us.census.acs.B15003017_quantile": "0.0403378378378378",
  "us.census.acs.B15003022_quantile": "0.285972972972973",
  "us.census.acs.B15003023_quantile": "0.214567567567568",
  "us.census.acs.B16001001_quantile": "0.0181621621621622",
  "us.census.acs.B16001002_quantile": "0.0463108108108108",
  "us.census.acs.B16001003_quantile": "0.540540540540541",
  "us.census.acs.B17001001_quantile": "0.0237567567567568",
  "us.census.acs.B17001002_quantile": "0.155972972972973",
  "us.census.acs.B19013001_quantile": "0.380662162162162",
  "us.census.acs.B19083001_quantile": "0.986891891891892",
  "us.census.acs.B19301001_quantile": "0.989594594594595",
  "us.census.acs.B25001001_quantile": "0.998418918918919",
  "us.census.acs.B25002003_quantile": "0.999824324324324",
  "us.census.acs.B25004002_quantile": "0.999986486486486",
  "us.census.acs.B25004004_quantile": "0.999662162162162",
  "us.census.acs.B25058001_quantile": "0.679054054054054",
  "us.census.acs.B25071001_quantile": "0.569716216216216",
  "us.census.acs.B25075001_quantile": "0.0415",
  "us.census.acs.B25075025_quantile": "0.891702702702703"
}
```

The possible segments are:

<table>
  <tr><th> X10 segment</th> <th> X55 Segment </th></tr>
  
  <tr><td> Hispanic and kids</td><td></td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #99C945'></div> Middle Class, Educated, Suburban, Mixed Race </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #a3ce57'></div> Low Income on Urban Periphery</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #add468'></div> Suburban, Young and Low-income  </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #b7d978'></div> low-income, urban, young, unmarried  </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #c1df88'></div> Low education, mainly suburban </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #cbe598'></div> Young, working class and rural  </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #d5eba8'></div> Low-Income with gentrification  </td></tr>
    
  <tr><td>Low Income and Diverse</td><td></td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #52BCA3'></div> High school education Long Commuters, Black, White Hispanic mix</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #66c5ae'></div> Rural, Bachelors or college degree, Rent owned mix</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #79cdb7'></div> Rural,High School Education, Owns property</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #8bd5c1'></div> Young, City based renters in Sparse neighborhoods, Low poverty   </td></tr>
    
  <tr><td>Low income, minority mix</td><td></td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #5D69B1'></div> Predominantly black, high high school attainment, home owners </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #7b83c6'></div> White and minority mix multilingual, mixed income / education. Married </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #9095d2'></div> Hispanic Black mix multilingual, high poverty, renters, uses public transport</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #a3a7df'></div>  Predominantly black renters, rent own mix </td></tr>
    
  <tr><td>Middle income, single family homes</td><td></td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #E58606'></div> Lower Middle Income with higher rent burden </td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #f0983b'></div> Black and mixed community with rent burden</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #f4a24e'></div> Lower Middle Income with affordable housing</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #f8ab5f'></div> Relatively affordable, satisfied lower middle class</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #fcb470'></div> Satisfied Lower Middle Income Higher Rent Costs</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #ffbe81'></div> Suburban/Rural Satisfied, decently educated lower middle class</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #ffc792'></div> Struggling lower middle class with rent burden</td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #ffd0a3'></div> Older white home owners, less comfortable financially </td></tr>
    <tr><td></td> <td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #ffdab4'></div> Older home owners, more financially comfortable, some diversity</td></tr>
    
  <tr><td>Native American</td><td></td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #2F8AC4'></div>Younger, poorer,single parent family Native Americans</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background: #77b8ee'></div>Older, middle income Native Americans once married and Educated </td></tr>
    
  <tr><td>Old Wealthy, White</td><td></td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#24796C'></div> Older, mixed race professionals</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#388d7e'></div> Works from home, Highly Educated, Super Wealthy </td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#4ca191'></div> Retired Grandparents</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#60b5a5'></div> Wealthy and Rural Living</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#73c9b8'></div> Wealthy, Retired Mountains/Coasts</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#87decc'></div> Wealthy Diverse Suburbanites On the Coasts</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#9bf3e1'></div> Retirement Communitties</td></tr>
    
  <tr><td>Low Income African American</td><td></td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#c23a7e'></div>Urban - Inner city</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#d86298'></div>Rural families</td></tr>
  <tr><td>Residential institutions, young people</td><td></td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#764e9f'></div>College towns</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#8a64b1'></div>College town with poverty</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#9e7ac3'></div>University campus wider area</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#b491d5'></div>City Outskirt University Campuses</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#c9a8e8'></div>City Center University Campuses</td></tr>
    
  <tr><td>Wealthy Nuclear Families</td><td></td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ed645a'></div>Lower educational attainment, Homeowner, Low rent</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ee7655'></div>Younger, Long Commuter in dense neighborhood</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#f38060'></div>Long commuters White black mix</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#f98a6b'></div>Low rent in built up neighborhoods</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#fe9576'></div>Renters within cities, mixed income areas, White/Hispanic mix, Unmarried</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ff9f82'></div>Older Home owners with high income</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ffa98d'></div>Older home owners and very high income</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ffb399'></div>White Asian Mix Big City Burbs Dwellers</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ffbda5'></div>Bachelors degree Mid income With Mortgages</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ffc8b1'></div>Asian Hispanic Mix, Mid income</td></tr>
    <tr><td></td><td><div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ffd2bd'></div>Bachelors degree Higher income Home Owners</td></tr>
    
  <tr><td>Wealthy, urban, and kid-free</td><td></td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#CC61B0'></div>Wealthy city commuters </td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#d975bd'></div>New Developments</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#e488c9'></div>Very wealthy, multiple million dollar homes</td></tr>
    <tr><td></td> <td> <div  style='float:left;margin-right:10px;width:20px; height:20px; border-radius:20px;background:#ee9ad4'></div>High rise, dense urbanites</td></tr>
</table>


#### Examples

```bash
https://{username}.carto.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentSnapshot({{point geometry}})
```

###### Get the Geographic Snapshot of a Segmentation

__Get the Segmentation Snapshot around the MGM Grand__


```bash
https://{username}.carto.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentSnapshot(CDB_LatLng(36.10222, -115.169516))
```

__Get the Segmentation Snapshot at CARTO's NYC HQ__


```bash
https://{username}.carto.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentSnapshot(CDB_LatLng(40.704512, -73.936669))
```

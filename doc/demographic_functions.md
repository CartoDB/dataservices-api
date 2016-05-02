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

The Demographic Snapshot contains a broad subset of demographic measures in the Data Observatory. Over 80 measurements are returned by a single API request. **For details, see [Glossary of Demographic Measures](#glossary-of-demographic-measures).

### Examples

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

## Glossary of Demographic Measures

This list contains the demographic measures and reponse names for results from the ```OBS_GetDemographicSnapshot``` function.

 Measure name | Measure Description | Response Mame | Response Units
---	|---	|--- |--- 
Total Population | The total number of all people living in a given geographic area. This is a very useful catch-all denominator when calculating rates. | total_pop | Count per sq. km 
Male Population | The number of people within each geography who are male. | male_pop | Count per sq. km
Female Population | The number of people within each geography who are female.| female_pop | Count per sq. km
Population not Hispanic	| The number of people not identifying as Hispanic or Latino in each geography. | not_hispanic_pop | Count per sq. km
White Population | The number of people identifying as white, non-Hispanic in each geography. | white_pop | Count per sq. km 
Black or African American Population| The number of people identifying as black or African American, non-Hispanic in each geography. | black_pop | Count per sq. km
American Indian and Alaska Native Population | The number of people identifying as American Indian or Alaska native in each geography.| amerindian_pop| Count per sq. km
Asian Population | The number of people identifying as Asian, non-Hispanic in each geography.| asian_pop | Count per sq. km
Other Race population | The number of people identifying as another race in each geography. | other_race_pop | Count per sq. km
Two or more races population| The number of people identifying as two or more races in each geography | two_or_more_races_pop | Count per sq. km
Hispanic Population | The number of people identifying as Hispanic or Latino in each geography. | hispanic_pop | Count per sq. km
Not a U.S. Citizen Population | The number of people within each geography who indicated that they are not U.S. citizens. | not_us_citizen_pop | Count per sq. km
Median Age | The median age of all people in a given geographic area.| median_age | Years
Children under 18 Years of Age | The number of people within each geography who are under 18 years of age.| children | Count per sq. km
Population 15 Years and Over | The number of people in a geographic area who are over the age of 15. This is used mostly as a denominator of marital status. | pop_15_and_over | Count per sq. km
Population 3 Years and Over | The total number of people in each geography age 3 years and over. This denominator is mostly used to calculate rates of school enrollment. | population_3_years_over | Count per sq. km
Population 5 Years and Over | The number of people in a geographic area who are over the age of 5. This is primarily used as a denominator of measures of language spoken at home.| pop_5_years_over | Count per sq. km
Workers over the Age of 16 | The number of people in each geography who work. Workers include those employed at private for-profit companies, the self-employed, government workers and non-profit employees. | workers_16_and_over | Count per sq. km
Workers age 16 and over who do not work from home| The number of workers over the age of 16 who do not work from home in a geographic area| commuters_16_over | Count per sq. km
Commuters by Car, Truck, or Van | The number of workers age 16 years and over within a geographic area who primarily traveled to work by car, truck or  van. This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. | commuters_by_car_truck_van | Count per sq. km
Commuters who drove alone | The number of workers age 16 years and over within a geographic area who primarily traveled by car driving alone. This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. | commuters_drove_alone | Count per sq. km
Commuters by Carpool| The number of workers age 16 years and over within a geographic area who primarily traveled to work by carpool. This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. | commuters_by_carpool | Count per sq. km
Commuters by Public Transportation 	| The number of workers age 16 years and over within a geographic area who primarily traveled to work by public transportation.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. | commuters_by_public_transportation 	| Count per sq. km 	|
Commuters by Bus | The number of workers age 16 years and over within a geographic area who primarily traveled to work by bus.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. This is a subset of workers who commuted by public transport. | commuters_by_bus| Count per sq. km
Commuters by Subway or Elevated | The number of workers age 16 years and over within a geographic area who primarily traveled to work by subway or elevated train. This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work. This is a subset of workers who commuted by public transport. | commuters_by_subway_or_elevated | Count per sq. km
Walked to Work | The number of workers age 16 years and over within a geographic area who primarily walked to work. This would mean that of any way of getting to work, they travelled the most distance walking. | walked_to_work | Count per sq. km
Worked at Home | The count within a geographical area of workers over the age of 16 who worked at home. | worked_at_home | Count per sq. km
Number of workers with less than 10 minute commute | The number of workers over the age of 16 who do not work from home and commute in less than 10 minutes in a geographic area. | commute_less_10_mins | Count per sq. km
Number of workers with a commute between 10 and 14 minutes| The number of workers over the age of 16 who do not work from home and commute in between 10 and 14 minutes in a geographic area. | commute_10_14_mins | Count per sq. km
Number of workers with a commute between 15 and 19 minutes | The number of workers over the age of 16 who do not work from home and commute in between 15 and 19 minutes in a geographic area. | commute_15_19_mins | Count per sq. km
Number of workers with a commute between 20 and 24 minutes | The number of workers over the age of 16 who do not work from home and commute in between 20 and 24 minutes in a geographic area. | commute_20_24_mins | Count per sq. km
Number of workers with a commute between 25 and 29 minutes | The number of workers over the age of 16 who do not work from home and commute in between 25 and 29 minutes in a geographic area. | commute_25_29_mins| Count per sq. km
Number of workers with a commute between 30 and 34 minutes | The number of workers over the age of 16 who do not work from home and commute in between 30 and 34 minutes in a geographic area. | commute_30_34_mins | Count per sq. km
Number of workers with a commute between 35 and 44 minutes | The number of workers over the age of 16 who do not work from home and commute in between 35 and 44 minutes in a geographic area. | commute_35_44_mins | Count per sq. km
Number of workers with a commute between 45 and 59 minutes | The number of workers over the age of 16 who do not work from home and commute in between 45 and 59 minutes in a geographic area. | commute_45_59_mins | Count per sq. km
Number of workers with a commute of over 60 minutes | The number of workers over the age of 16 who do not work from home and commute in over 60 minutes in a geographic area.| commute_60_more_mins | Count per sq. km
Aggregate travel time to work | The total number of minutes every worker over the age of 16 who did not work from home spent spent commuting to work in one day in a geographic area. | aggregate_travel_time_to_work | Minutes
Households | A count of the number of households in each geography. A household consists of one or more people who live in the same dwelling and also share at meals or living accommodation, and may consist of a single family or some other grouping of people. | households | Count per sq. km
Never Married | The number of people in a geographic area who have never been married. | pop_never_married | Count per sq. km
Currently married| The number of people in a geographic area who are currently married. | pop_now_married | Count per sq. km
Married but separated | The number of people in a geographic area who are married but separated.| pop_separated | Count per sq. km
Widowed | The number of people in a geographic area who are widowed.| pop_widowed | Count per sq. km
Divorced | The number of people in a geographic area who are divorced. | pop_divorced | Count per sq. km
Students Enrolled in School | The total number of people in each geography currently enrolled at any level of school, from nursery or pre-school to advanced post-graduate education. Only includes those over the age of 3. | in_school | Count per sq. km
Students Enrolled in Grades 1 to 4 | The total number of people in each geography currently enrolled in grades 1 through 4 inclusive.  This corresponds roughly to elementary school. | in_grades_1_to_4 | Count per sq. km
Students Enrolled in Grades 5 to 8 | The total number of people in each geography currently enrolled in grades 5 through 8 inclusive.  This corresponds roughly to middle school. | in_grades_5_to_8 | Count per sq. km
Students Enrolled in Grades 9 to 12 | The total number of people in each geography currently enrolled in grades 9 through 12 inclusive.  This corresponds roughly to high school. | in_grades_9_to_12 | Count per sq. km
Students Enrolled as Undergraduate in College | The number of people in a geographic area who are enrolled in college at the undergraduate level. Enrollment refers to being registered or listed as a student in an educational program leading to a college degree. This may be a public school or college, a private school or college. | in_undergrad_college | Count per sq. km
Population 25 Years and Over | The number of people in a geographic area who are over the age of 25. This is used mostly as a denominator of educational attainment. | pop_25_years_over | Count per sq. km
Population Completed High School | The number of people in a geographic area over the age of 25 who completed high school, and did not complete a more advanced degree.	| high_school_diploma| Count per sq. km
Population completed less than one year of college, no degree | The number of people in a geographic area over the age of 25 who attended college for less than one year and no further. | less_one_year_college | Count per sq. km
Population completed more than one year of college, no degree | The number of people in a geographic area over the age of 25 who attended college for more than one year but did not obtain a degree. | one_year_more_college | Count per sq. km
Population Completed Associate's Degree | The number of people in a geographic area over the age of 25 who obtained a associate's degree, and did not complete a more advanced degree.| associates_degree | Count per sq. km
Population Completed Bachelor's Degree| The number of people in a geographic area over the age of 25 who obtained a bachelor's degree, and did not complete a more advanced degree. | bachelors_degree| Count per sq. km
Population Completed Master's Degree | The number of people in a geographic area over the age of 25 who obtained a master's degree, but did not complete a more advanced degree. | masters_degree | Count per sq. km
Speaks only English at Home | The number of people in a geographic area over age 5 who speak only English at home. | speak_only_english_at_home | Count per sq. km
Speaks Spanish at Home | The number of people in a geographic area over age 5 who speak Spanish at home, possibly in addition to other languages. | speak_spanish_at_home | Count per sq. km
Population for Whom Poverty Status Determined | The number of people in each geography who could be identified as either living in poverty or not.  This should be used as the denominator when calculating poverty rates, as it excludes people for whom it was not possible to determine poverty. | pop_determined_poverty_status | Count per sq. km
Income In The Past 12 Months Below Poverty Level | The number of people in a geographic area who are part of a family (which could be just them as an individual) determined to be "in poverty" following the [Office of Management and Budget's Directive 14](https://www.census.gov/hhes/povmeas/methodology/ombdir14.html). | poverty | Count per sq. km
Households with income less than $10,000 | The number of households in a geographic area whose annual income was less than $10,000. | income_less_10000 | Count per sq. km
Households with income of $10,000 to $14,999 | The number of households in a geographic area whose annual income was between $10,000 and $14,999. | income_10000_14999 | Count per sq. km
Households with income of $15,000 to $19,999 | The number of households in a geographic area whose annual income was between $15,000 and $19,999. | income_15000_19999 | Count per sq. km
Households with income of $20,000 To $24,999 | The number of households in a geographic area whose annual income was between $20,000 and $24,999. | income_20000_24999 | Count per sq. km
Households with income of $25,000 To $29,999 | The number of households in a geographic area whose annual income was between $20,000 and $24,999. | income_25000_29999 | Count per sq. km
Households with income of $30,000 To $34,999 | The number of households in a geographic area whose annual income was between $30,000 and $34,999. | income_30000_34999 | Count per sq. km
Households with income of $35,000 To $39,999 | The number of households in a geographic area whose annual income was between $35,000 and $39,999. | income_35000_39999 | Count per sq. km
Households with income of $40,000 To $44,999 | The number of households in a geographic area whose annual income was between $40,000 and $44,999. | income_40000_44999| Count per sq. km
Households with income of $45,000 To $49,999 | The number of households in a geographic area whose annual income was between $45,000 and $49,999. | income_45000_49999 | Count per sq. km
Households with income of $50,000 To $59,999 | The number of households in a geographic area whose annual income was between $50,000 and $59,999. | income_50000_59999 | Count per sq. km
Households with income of $60,000 To $74,999 | The number of households in a geographic area whose annual income was between $60,000 and $74,999. | income_60000_74999 | Count per sq. km
Households with income of $75,000 To $99,999 | The number of households in a geographic area whose annual income was between $75,000 and $99,999. | income_75000_99999 | Count per sq. km
Households with income of $100,000 To $124,999 | The number of households in a geographic area whose annual income was between $100,000 and $124,999. | income_100000_124999 | Count per sq. km
Households with income of $125,000 To $149,999 | The number of households in a geographic area whose annual income was between $125,000 and $149,999. | income_125000_149999 | Count per sq. km
Households with income of $150,000 To $199,999 | The number of households in a geographic area whose annual income was between $150,000 and $1999,999. | income_150000_199999 | Count per sq. km
Households with income of $200,000 Or More | The number of households in a geographic area whose annual income was more than $200,000. | income_200000_or_more | Count per sq. km
Median Household Income in the past 12 Months | Within a geographic area, the median income received by every household on a regular basis before payments for personal income taxes, social security, union dues, medicare deductions, etc.  It includes income received from wages, salary, commissions, bonuses, and tips; self-employment income from own nonfarm or farm businesses, including proprietorships and partnerships; interest, dividends, net rental income, royalty income, or income from estates and trusts; Social Security or Railroad Retirement income; Supplemental Security Income (SSI); any cash public assistance or welfare payments from the state or local welfare office; retirement, survivor, or disability benefits; and any other sources of income received regularly such as Veterans' (VA) payments, unemployment and/or worker's compensation, child support, and alimony. | median_income | USD
Per Capita Income in the past 12 Months |  	| income_per_capita | USD
Gini Index | A measurement of the income distribution of a country's residents. | gini_index | None
Housing Units | A count of housing units in each geography. A housing unit is a house, an apartment, a mobile home or trailer, a group of rooms, or a single room occupied as separate living quarters, or if vacant, intended for occupancy as separate living quarters. | housing_units | Count per sq. km
Vacant Housing Units | The count of vacant housing units in a geographic area. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant. | vacant_housing_units | Count per sq. km
Vacant Housing Units for Rent | The count of vacant housing units in a geographic area that are for rent. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant. | vacant_housing_units_for_rent | Count per sq. km
Vacant Housing Units for Sale| The count of vacant housing units in a geographic area that are for sale. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant. | vacant_housing_units_for_sale | Count per sq. km
Owner-occupied Housing Units | The count of owner occupied housing units in a geographic area. | owner_occupied_housing_units | Count per sq. km
Owner-occupied Housing Units valued at $1,000,000 or more. | The count of owner occupied housing units in a geographic area that are valued at $1,000,000 or more. Value is the respondent's estimate of how much the property (house and lot, mobile home and lot, or condominium unit) would sell for if it were for sale. | million_dollar_housing_units | Count per sq. km
Owner-occupied Housing Units with a Mortgage | The count of housing units within a geographic area that are mortagaged. "Mortgage" refers to all forms of debt where the property is pledged as security for repayment of the debt, including deeds of trust, trust deed, contracts to purchase, land contracts, junior mortgages, and home equity loans. | mortgaged_housing_units | Count per sq. km
Median Rent | The median contract rent within a geographic area. The contract rent is the monthly rent agreed to or contracted for, regardless of any furnishings, utilities, fees, meals, or services that may be included. For vacant units, it is the monthly rent asked for the rental unit at the time of interview.| median_rent | USD
Percent of Household Income Spent on Rent | Within a geographic area, the median percentage of household income which was spent on gross rent.  Gross rent is the amount of the contract rent plus the estimated average monthly cost of utilities (electricity, gas, water, sewer etc.) and fuels (oil, coal, wood, etc.) if these are paid by the renter. Household income is the sum of the income of all people 15 years and older living in the household. | percent_income_spent_on_rent | Percent

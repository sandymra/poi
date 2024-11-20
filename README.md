## Description

Implementation of stored procedure to find POIs based on search criteria using geospatial data.

## Input parameter

Search criteria is passed to the stored procedure in JSON format as one input parameter.
</br>
List of criteria:
1. country_code 
2. region
3. city
4. coordinates.latitude
5. coordinates.longitude
6. coordinates.radius
7. polygon_wkt
8. category
9. location_name
 
 </br>
Any criteria may be omitted.
</br>
Order of criteria is irrelevant.
</br>
Criteria location_name, category, city are using LIKE to match specified pattern in a column. 

<b>Valid format of incoming JSON Request with all criteria supplied</b>

```
'{
	"Request":
	{
		"country_code": "US",
		"region": "AZ",
		"city": "Phoenix",
		"coordinates":
			{
				"latitude":33.586564,
				"longitude":-112.122569,
				"radius": 400
			},
		"polygon_wkt": "POLYGON ((-112.124095 33.5869328, -112.124095 33.5848593, -112.1197927 33.584904, -112.1199751 33.5872501, -112.124095 33.5869328))",
		"category": "Agencies",
		"location_name": "Fasula Kaplan Insurance Agency"
	}
}'
```

<b>Valid format of incoming JSON Request parameter with all criteria ommited</b>

```
'{
	"Request":
	{
	}
}'
```

If no search criteria is submitted all POIs within 200 meters of the current location will be returned using dummy location as the current one.

</br></br>
Dummy location:
</br>
Latitude: 33.480639
</br>
Longitude: -112.035032
</br>
City: Phoenix
</br>
Region: AZ

Search criteria could be validated in the backend service when creating request. 
</br>
In that case, exact location with radius could be supplied in the request with the current location and default radius.
</br>

<b>Valid format of incoming JSON Request with dummy location and radius in the request</b>

```
'{
	"Request":
	{
		"coordinates":
			{
				"latitude":33.480639,
				"longitude":-112.035032,
				"radius": 200
			}
	}
}'
```


### Output parameter

Stored procedure is using output parameter to return data.
</br>
Data is returned in the valid GeoJSON format compressed by SQL Server.

<b>Expected GeoJson result for backend service</b>

```
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          33.586564,
          -112.122569
        ]
      },
      "properties": {
        "id": "zzw-227@5zb-wwd-nqz",
        "country_code": "US",
        "region_code": "AZ",
        "city": "Phoenix",
        "latitude": 33.586564,
        "longitude": -112.122569,
        "category": "Agencies, Brokerages, and Other Insurance Related Activities",
        "polygon_wkt": "POLYGON ((-112.12226698599994 33.586266623000029, -112.12226546399995 33.585951039000065, -112.12255022899996 33.585950104000062, -112.12255139499996 33.58619182800004, -112.12272293499996 33.58633227200005, -112.122724458 33.586647855000024, -112.12244782799996 33.586648763000028, -112.12244669399996 33.586413755000024, -112.12226698599994 33.586266623000029))",
        "location_name": "Fasula Kaplan Insurance Agency",
        "postal_code": "85029",
        "operation_hours": [
          {
            "day": "Mon",
            "hours": "[[\"9:00\", \"17:00\"]]"
          },
          {
            "day": "Tue",
            "hours": "[[\"9:00\", \"17:00\"]]"
          },
          {
            "day": "Wed",
            "hours": "[[\"9:00\", \"17:00\"]]"
          },
          {
            "day": "Thu",
            "hours": "[[\"9:00\", \"17:00\"]]"
          },
          {
            "day": "Fri",
            "hours": "[[\"9:00\", \"17:00\"]]"
          },
          {
            "day": "Sat",
            "hours": "[]"
          },
          {
            "day": "Sun",
            "hours": "[]"
          }
        ]
      }
    }
  ]
}
```

<b>Expected GeoJson result for backend service when search criteria is not met</b>

```
{'type': 'FeatureCollection', 'features': []}
```

Stored procedure expects validated JSON incoming request.
</br>
However blocks that parse json request data and retrieve data from the tables are wrapped inside Try/Catch.
</br>
Explicit casting of the search criteria is implemented to prevent invalid request.

<b>Expected GeoJson result for backend service when exception is thrown</b>

```
{'type': 'FeatureCollection', 'features': []}
```

## How to execute a stored procedure in SQL Server

```
USE [POI]
GO

DECLARE	@return_value int,
		@GeoJsonResponse nvarchar(max)

EXEC	@return_value = [dbo].[uspGetPointsOfInterest]
		@JsonRequest = '{
					"Request":
						{
							"coordinates":
								{
									"latitude":33.586564,
									"longitude":-112.122569,
									"radius": 200
								}
						}
				}',
@GeoJsonResponse = @GeoJsonResponse OUTPUT

SELECT	@GeoJsonResponse as N'@GeoJsonResponse'
```

### Database backup

Full database backup with schema and data in the repository
</br>
POI_20241120.zip


## Authors

Sanda Mracevic
</br>
Email: sanda.mracevic@gmail.com
</br>
Linkedin: https://www.linkedin.com/in/sanda-mracevic-3076b917/

## Version History

* 0.1
    * Initial Release


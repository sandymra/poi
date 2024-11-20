-- =============================================
-- Author:		Sanda Mracevic
-- Create date: 11/20/2024
-- Description:	Database Engineer Challenge
--			    Enrich software with POI data 
-- =============================================
CREATE PROCEDURE [dbo].[uspGetPointsOfInterest] 
	@JsonRequest NVARCHAR(MAX),
	@GeoJsonResponse NVARCHAR(MAX) OUTPUT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	DECLARE @GeoJsonFeature NVARCHAR(MAX)
	DECLARE @GeoJsonFeatureCollection NVARCHAR(MAX)
	DECLARE @CountryCode NVARCHAR(2)
	DECLARE @RegionCode NVARCHAR(2)
	DECLARE @CityName NVARCHAR(100)
	DECLARE @Latitude DECIMAL(8,6)
	DECLARE @Longitude DECIMAL(9,6)
	DECLARE @Radius INT
	DECLARE @PolygonWkt GEOMETRY
	DECLARE @Polygon GEOGRAPHY
	DECLARE @GeoPoint GEOGRAPHY
	DECLARE @CategoryName NVARCHAR(100)
	DECLARE @LocationName NVARCHAR(255)

	DECLARE @HasSearchCriteria BIT

	DECLARE @CurrentGeoPoint GEOGRAPHY = geography::Point(33.480639, -112.035032, 4326) -- Dummy location in Phoenix, AZ

	SET NOCOUNT ON;

	BEGIN TRY
  
		-- 1. Parse Json Request
		BEGIN

			SELECT	@CountryCode = json.CountryCode,
					@RegionCode = json.RegionCode,
					@CityName = json.CityName,
					@Latitude = json.Latitude,
					@Longitude = json.Longitude,
					@Radius = json.Radius,
					@PolygonWkt = json.PolygonWkt,
					@CategoryName = json.CategoryName,
					@LocationName = json.LocationName
			FROM OPENJSON(@JsonRequest, '$.Request') WITH (CountryCode NVARCHAR(2) '$.country_code',
														   RegionCode NVARCHAR(2) '$.region',
														   CityName NVARCHAR(100) '$.city',
														   Latitude DECIMAL(8,6) '$.coordinates.latitude',
														   Longitude DECIMAL(9,6) '$.coordinates.longitude',
														   Radius INT '$.coordinates.radius',
														   PolygonWkt NVARCHAR(MAX) '$.polygon_wkt',
														   CategoryName NVARCHAR(100) '$.category',
														   LocationName NVARCHAR(255) '$.location_name') json

		END

		-- 2. Check if search criteria is supplied
		BEGIN

			SET @HasSearchCriteria = (CASE
										WHEN @CountryCode IS NULL AND
											 @RegionCode IS NULL AND
											 @CityName IS NULL AND
											 @Latitude IS NULL AND
											 @Longitude IS NULL AND
											 @Radius IS NULL AND
											 @PolygonWkt IS NULL AND
											 @CategoryName IS NULL AND
											 @LocationName IS NULL THEN 0
										ELSE 1
									  END ) 
		END

		-- 3. Get POIs
		IF @HasSearchCriteria = 1
			BEGIN	
			
				IF @Latitude IS NOT NULL AND @Longitude IS NOT NULL AND @Radius IS NOT NULL
					BEGIN
						SET @GeoPoint = geography::Point(@Latitude, @Longitude, 4326)
					END	
			
				IF @PolygonWkt IS NOT NULL
					BEGIN
						SET @Polygon = @PolygonWkt.MakeValid().STUnion(@PolygonWkt.STStartPoint()).STAsText() -- Fixing Polygon Ring Orientation problem
					END

				SET @GeoJsonFeature = 
					(
						SELECT	
							'Feature' AS [type],
							JSON_QUERY(dbo.ufnGeometryToJson(geometry::Point(loc.Latitude,loc.Longitude,4326))) AS [geometry],
							loc.LocationId AS 'properties.id',
							loc.LocationParentID AS 'properties.parent_id',
							ctr.CountryCode AS 'properties.country_code',
							reg.RegionCode AS 'properties.region_code',
							cty.CityName AS 'properties.city',
							loc.Latitude AS 'properties.latitude',
							loc.Longitude AS'properties.longitude',
							cat1.CategoryName AS 'properties.category',
							cat2.CategoryName AS 'properties.sub_category',
							loc.PolygonWkt.ToString() AS 'properties.polygon_wkt',
							loc.LocationName AS 'properties.location_name',
							loc.PostalCode AS 'properties.postal_code',
							(SELECT [Day] AS 'day',
									[OperationHours] AS 'hours'    
							 FROM LocationOperationHour
							 WHERE LocationID = loc.LocationID
							 FOR JSON PATH) AS 'properties.operation_hours'
						FROM Location loc
						INNER JOIN City cty ON cty.CityID = loc.CityID
						INNER JOIN Region reg ON reg.RegionID = cty.RegionID
						INNER JOIN Country ctr ON ctr.CountryID = reg.CountryID
						LEFT JOIN Category cat1 ON cat1.CategoryID = loc.CategoryID
						LEFT JOIN Category cat2 ON cat1.ParentCategoryID = cat2.CategoryID
						WHERE (@CountryCode IS NULL OR ctr.CountryCode = @CountryCode) AND
							  (@RegionCode IS NULL OR reg.RegionCode = @RegionCode) AND
							  (@CityName IS NULL OR cty.CityName LIKE '%' + @CityName + '%')  AND								  
							  (@GeoPoint IS NULL OR (loc.GeoPoint.STDistance(@GeoPoint)) <= @Radius) AND
							  (@Polygon IS NULL OR (@Polygon.STIntersects(loc.GeoPoint) = 1)) AND
							  (@CategoryName IS NULL OR cat1.CategoryName LIKE '%' + @CategoryName + '%') AND
							  (@LocationName IS NULL OR loc.LocationName LIKE '%' + @LocationName + '%')
						FOR JSON PATH
					)

			END
		ELSE
			-- If no search criteria is selected, all POIs within 200 meters of the current location are returned
			BEGIN

				SET @GeoJsonFeature = 
					(
						SELECT	
							'Feature' AS [type],
							JSON_QUERY(dbo.ufnGeometryToJson(geometry::Point(loc.Latitude,loc.Longitude,4326))) AS [geometry],
							loc.LocationId AS 'properties.id',
							loc.LocationParentID AS 'properties.parent_id',
							ctr.CountryCode AS 'properties.country_code',
							reg.RegionCode AS 'properties.region_code',
							cty.CityName AS 'properties.city',
							loc.Latitude AS 'properties.latitude',
							loc.Longitude AS'properties.longitude',
							cat1.CategoryName AS 'properties.category',
							cat2.CategoryName AS 'properties.sub_category',
							loc.PolygonWkt.ToString() AS 'properties.polygon_wkt',
							loc.LocationName AS 'properties.location_name',
							loc.PostalCode AS 'properties.postal_code',
							(SELECT [Day] AS 'day',
									[OperationHours] AS 'hours'       
								FROM LocationOperationHour
								WHERE LocationID = loc.LocationID
								FOR JSON PATH) AS 'properties.operation_hours'
						FROM Location loc
						INNER JOIN City cty ON cty.CityID = loc.CityID
						INNER JOIN Region reg ON reg.RegionID = cty.RegionID
						INNER JOIN Country ctr ON ctr.CountryID = reg.CountryID
						LEFT JOIN Category cat1 ON cat1.CategoryID = loc.CategoryID
						LEFT JOIN Category cat2 ON cat1.ParentCategoryID = cat2.CategoryID
						WHERE loc.GeoPoint.STDistance(@CurrentGeoPoint) <= 200
						FOR JSON PATH
					)

			END
		
		-- 4. RETURN GEOJSON 
		BEGIN
			IF @GeoJsonFeature <> ''
				BEGIN

					SET @GeoJsonFeatureCollection = 
						(
							SELECT 'FeatureCollection' AS [type], 
									JSON_QUERY(@GeoJsonFeature) AS 'features'
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
						)

				END
			ELSE
				BEGIN
					SET @GeoJsonFeatureCollection = '{''type'': ''FeatureCollection'', ''features'': []}'
				END

		END

END TRY
BEGIN CATCH

	SET @GeoJsonFeatureCollection = '{''type'': ''FeatureCollection'', ''features'': []}'

END CATCH;


SET @GeoJsonResponse = @GeoJsonFeatureCollection


END

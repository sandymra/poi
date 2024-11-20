CREATE TABLE [dbo].[Location] (
    [LocationID]       NVARCHAR (50)     NOT NULL,
    [LocationParentID] NVARCHAR (50)     NULL,
    [CategoryID]       INT               NULL,
    [CityID]           INT               NULL,
    [LocationName]     NVARCHAR (255)    NOT NULL,
    [PostalCode]       NVARCHAR (5)      NULL,
    [Latitude]         DECIMAL (8, 6)    NULL,
    [Longitude]        DECIMAL (9, 6)    NULL,
    [PolygonWkt]       [sys].[geography] NULL,
    [GeoPoint]         AS                ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
    CONSTRAINT [PK_PointOfInterest] PRIMARY KEY CLUSTERED ([LocationID] ASC),
    CONSTRAINT [FK_PointOfInterest_CategoryID] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Category] ([CategoryID]),
    CONSTRAINT [FK_PointOfInterest_CityID] FOREIGN KEY ([CityID]) REFERENCES [dbo].[City] ([CityID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Location_CityID]
    ON [dbo].[Location]([CityID] ASC)
    INCLUDE([LocationParentID], [CategoryID], [LocationName], [PostalCode], [Latitude], [Longitude], [PolygonWkt], [GeoPoint]);


GO
CREATE NONCLUSTERED INDEX [IX_Location_CategoryID]
    ON [dbo].[Location]([CategoryID] ASC);


GO
CREATE SPATIAL INDEX [SPIX_Location_PolygonWkt]
    ON [dbo].[Location] ([PolygonWkt]);


GO
CREATE SPATIAL INDEX [SPIX_Location_GeoPoint]
    ON [dbo].[Location] ([GeoPoint]);


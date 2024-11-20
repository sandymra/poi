CREATE TABLE [dbo].[Region] (
    [RegionID]   INT          IDENTITY (1, 1) NOT NULL,
    [CountryID]  INT          NULL,
    [RegionCode] NVARCHAR (2) NULL,
    CONSTRAINT [PK_Region] PRIMARY KEY CLUSTERED ([RegionID] ASC),
    CONSTRAINT [FK_Region_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Country] ([CountryID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Region_CountryID]
    ON [dbo].[Region]([CountryID] ASC);


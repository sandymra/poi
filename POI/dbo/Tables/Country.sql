CREATE TABLE [dbo].[Country] (
    [CountryID]   INT          IDENTITY (1, 1) NOT NULL,
    [CountryCode] NVARCHAR (2) NULL,
    CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED ([CountryID] ASC)
);


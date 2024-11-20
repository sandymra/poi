CREATE TABLE [dbo].[City] (
    [CityID]   INT            IDENTITY (1, 1) NOT NULL,
    [RegionID] INT            NULL,
    [CityName] NVARCHAR (100) NULL,
    CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED ([CityID] ASC),
    CONSTRAINT [FK_City_RegionID] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Region] ([RegionID])
);


GO
CREATE NONCLUSTERED INDEX [IX_City_RegionID]
    ON [dbo].[City]([RegionID] ASC);


CREATE TABLE [dbo].[LocationCategoryTag] (
    [LocationCategoryTagID] INT           IDENTITY (1, 1) NOT NULL,
    [LocationID]            NVARCHAR (50) NULL,
    [CategoryTagID]         INT           NULL,
    CONSTRAINT [PK_LocationCategoryTag] PRIMARY KEY CLUSTERED ([LocationCategoryTagID] ASC),
    CONSTRAINT [FK_LocationCategoryTag_CategoryTagID] FOREIGN KEY ([CategoryTagID]) REFERENCES [dbo].[CategoryTag] ([CategoryTagID]),
    CONSTRAINT [FK_LocationCategoryTag_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Location] ([LocationID])
);


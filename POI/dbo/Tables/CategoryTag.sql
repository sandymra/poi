CREATE TABLE [dbo].[CategoryTag] (
    [CategoryTagID]   INT           IDENTITY (1, 1) NOT NULL,
    [CategoryTagName] NVARCHAR (50) NULL,
    CONSTRAINT [PK_CategoryTag] PRIMARY KEY CLUSTERED ([CategoryTagID] ASC)
);


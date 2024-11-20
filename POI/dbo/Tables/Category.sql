CREATE TABLE [dbo].[Category] (
    [CategoryID]       INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName]     NVARCHAR (100) NOT NULL,
    [ParentCategoryID] INT            NULL,
    CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);


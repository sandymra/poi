CREATE TABLE [dbo].[LocationOperationHour] (
    [LocationOperationHourID] INT            IDENTITY (1, 1) NOT NULL,
    [LocationID]              NVARCHAR (50)  NULL,
    [Day]                     NVARCHAR (3)   NULL,
    [OperationHours]          NVARCHAR (100) NULL,
    CONSTRAINT [PK_LocationOperationHours] PRIMARY KEY CLUSTERED ([LocationOperationHourID] ASC),
    CONSTRAINT [FK_LocationOperationHours_LocationID] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Location] ([LocationID])
);


GO
CREATE NONCLUSTERED INDEX [IX_LocationOperationHour_LocationID]
    ON [dbo].[LocationOperationHour]([LocationID] ASC);


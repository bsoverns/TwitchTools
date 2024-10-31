CREATE TABLE [dbo].[Events]
 (
  [EventId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [EventType] VARCHAR(50),
  [EventTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_Events_EventTimestampUtc] DEFAULT GETUTCDATE(),
  CONSTRAINT [PK_Events_EventId] PRIMARY KEY CLUSTERED ([EventId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Events_UserId]
ON [dbo].[Events] ([UserId] ASC)
INCLUDE ([EventType], [EventTimestampUtc])
WITH (ONLINE = ON);
GO
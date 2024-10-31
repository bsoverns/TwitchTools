CREATE TABLE [dbo].[Commands]
(
  [CommandId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [CommandText] VARCHAR(50) NOT NULL,
  [CommandTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_Commands_CommandTimestampUtc] DEFAULT GETUTCDATE(),
  CONSTRAINT [PK_Commands_CommandId] PRIMARY KEY CLUSTERED ([CommandId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Commands_UserId]
ON [dbo].[Commands] ([UserId] ASC)
INCLUDE ([CommandText], [CommandTimestampUtc])
WITH (ONLINE = ON);
GO

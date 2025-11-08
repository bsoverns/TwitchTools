CREATE TABLE [dbo].[Warnings]
(
  [WarningId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [WarnedBy] varchar(50) NOT NULL,
  [WarningReason] varchar(500) NOT NULL,
  [WarningTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_Warnings_WarningTimestampUtc] DEFAULT GETUTCDATE(),  
  [IsComplete] BIT NOT NULL CONSTRAINT [DF_Warnings_IsComplete] DEFAULT 0,
  CONSTRAINT [PK_Warnings_WarningId] PRIMARY KEY CLUSTERED ([WarningId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Warnings_UserId]
ON [dbo].[Warnings] ([UserId] ASC)
INCLUDE ([WarnedBy], [WarningReason], [IsComplete])
WITH (ONLINE = ON);
GO

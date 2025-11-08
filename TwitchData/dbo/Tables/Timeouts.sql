CREATE TABLE [dbo].[Timeouts]
(
  [TimeoutId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [TimeoutBy] VARCHAR(50) NOT NULL,
  [TimeoutTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_Timeouts_TimeoutTimestampUtc] DEFAULT GETUTCDATE(),
  [TimeoutReason] VARCHAR(500) NOT NULL,
  [TimeoutDurationInMinutes] INT NOT NULL,
  [IsComplete] BIT NOT NULL CONSTRAINT [DF_Timeouts_IsComplete] DEFAULT 0,
  CONSTRAINT [PK_Timeouts_TimeoutId] PRIMARY KEY CLUSTERED ([TimeoutId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Timeouts_UserId]
ON [dbo].[Timeouts] ([UserId] ASC)
INCLUDE ([TimeoutBy], [TimeoutReason], [TimeoutDurationInMinutes], [IsComplete])
WITH (ONLINE = ON);
GO
CREATE TABLE [dbo].[Bans]
(
  [BanId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [BannedBy] VARCHAR(50) NOT NULL,
  [BannedTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_Bans_BannedTimestampUtc] DEFAULT GETUTCDATE(),
  [BannedReason] VARCHAR(500),
  [IsActive] BIT NOT NULL CONSTRAINT [DF_Bans_IsActive] DEFAULT 1,
  CONSTRAINT [PK_Bans_BanId] PRIMARY KEY CLUSTERED ([BanId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Bans_UserId]
ON [dbo].[Bans] ([UserId] ASC)
INCLUDE ([BannedBy], [BannedReason], [IsActive])
WITH (ONLINE = ON);
GO
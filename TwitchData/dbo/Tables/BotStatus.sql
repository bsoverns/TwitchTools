﻿CREATE TABLE [dbo].[BotStatus]
(
	[BotStatusId] INT IDENTITY(1, 1) NOT NULL,
	[BotName] VARCHAR(50) NULL,
	[IsLive] BIT NOT NULL CONSTRAINT [DF_BotStatus_IsLive] DEFAULT 0,
	[LastUpdated] DATETIME NOT NULL CONSTRAINT [DF_BotStatus_LastUpdated] DEFAULT GETUTCDATE(),
	CONSTRAINT [PK_BotStatus_BotStatusId] PRIMARY KEY CLUSTERED ([BotStatusID] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_BotStatus_BotName]
ON [dbo].[BotStatus] ([BotName] ASC)
INCLUDE ([IsLive])
WITH (ONLINE = ON);
GO
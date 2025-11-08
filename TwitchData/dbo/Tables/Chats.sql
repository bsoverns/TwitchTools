CREATE TABLE [dbo].[Chats]
(
  [ChatId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [ChatMessage] VARCHAR(500) NOT NULL,
  [ChannelName] VARCHAR(50) NULL,
  [TimeStampUtc] DATETIME NOT NULL CONSTRAINT [DF_Chats_TimeStampUtc] DEFAULT GETUTCDATE(),  
  [IsCommand] BIT NOT NULL CONSTRAINT [DF_Chats_IsCommand] DEFAULT 0,
  [IsModerated] BIT NOT NULL CONSTRAINT [DF_Chats_IsModerated] DEFAULT 0,
  [IsFlagged] BIT NOT NULL CONSTRAINT [DF_Chats_IsFlagged] DEFAULT 0,
  [FlaggedReason] VARCHAR(500) NULL,
  [IsTextToSpeech] BIT NOT NULL CONSTRAINT [DF_Chats_IsTextToSpeech] DEFAULT 0,
  [TtsCompletedTimestampUtc] DATETIME NULL,
  [IsTtsComplete] BIT NOT NULL CONSTRAINT [DF_Chats_IsComplete] DEFAULT 0,
  CONSTRAINT [PK_Chats_ChatId] PRIMARY KEY CLUSTERED ([ChatId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_UserId]
ON [dbo].[Chats] ([UserId] ASC)
INCLUDE ([ChatMessage], [IsCommand])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_IsModerated]
ON [dbo].[Chats] ([IsModerated] ASC)
INCLUDE ([ChatMessage])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_IsFlagged]
ON [dbo].[Chats] ([IsFlagged] ASC)
INCLUDE ([ChatMessage], [FlaggedReason])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_IsTextToSpeech]
ON [dbo].[Chats] ([IsTextToSpeech] ASC)
INCLUDE ([TtsCompletedTimestampUtc], [IsTtsComplete])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_TimeStampUtc]
ON [dbo].[Chats] ([TimeStampUtc] ASC)
WITH (ONLINE = ON);
GO
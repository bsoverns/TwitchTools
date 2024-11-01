CREATE TABLE [dbo].[Chats]
(
  [ChatId] INT IDENTITY(1, 1) NOT NULL,
  [UserId] INT NOT NULL,
  [ChatMessage] VARCHAR(500) NOT NULL,
  [TimeStampUtc] DATETIME NOT NULL CONSTRAINT [DF_Chats_TimeStampUtc] DEFAULT GETUTCDATE(),
  [IsCommand] BIT NOT NULL CONSTRAINT [DF_Chats_IsCommand] DEFAULT 0,
  CONSTRAINT [PK_Chats_ChatId] PRIMARY KEY CLUSTERED ([ChatId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Chats_UserId]
ON [dbo].[Chats] ([UserId] ASC)
INCLUDE ([ChatMessage], [IsCommand])
WITH (ONLINE = ON);
GO

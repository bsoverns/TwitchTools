CREATE TABLE [dbo].[ChatBotResponse]
(
	[ChatBotResponseId] INT IDENTITY(1, 1) NOT NULL,
	[ChatId] INT NOT NULL,
	[ResponseMessage] VARCHAR(500) NOT NULL,
	[TimeStampUtc] DATETIME NOT NULL CONSTRAINT [DF_ChatBotResponse_TimeStampUtc] DEFAULT GETUTCDATE(),  
	CONSTRAINT [PK_ChatBotResponse] PRIMARY KEY CLUSTERED ([ChatBotResponseId] ASC),
	CONSTRAINT [FK_ChatBotResponse_ChatId] FOREIGN KEY ([ChatId]) REFERENCES dbo.Chats([ChatId])
);
GO

CREATE NONCLUSTERED INDEX [IX_ChatBotResponse_ChatId]
ON [dbo].[ChatBotResponse] ([ChatId] ASC)
INCLUDE ([ResponseMessage])
WITH (ONLINE = ON);
GO
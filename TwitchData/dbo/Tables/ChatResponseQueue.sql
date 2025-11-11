CREATE TABLE [dbo].[ChatResponseQueue]
(
	[ChatResponseQueueId] INT NOT NULL IDENTITY(1, 1),
	[ChatId] INT NOT NULL,	
	[CreatedDateTimeUtc] DATETIME NOT NULL CONSTRAINT [DF_ChatResponseQueue_CreatedDateTimeUtc] DEFAULT GETUTCDATE(),
	[ProcessedDateTimeUtc] DATETIME NULL,
	[Processed] BIT NOT NULL CONSTRAINT [DF_ChatResponseQueue_Processed] DEFAULT 0,
	CONSTRAINT [PK_ChatResponseQueue_ChatResponseQueueId] PRIMARY KEY CLUSTERED ([ChatResponseQueueId] ASC),
	CONSTRAINT [FK_ChatResponseQueue_Chats_ChatId] FOREIGN KEY ([ChatId]) REFERENCES [dbo].[Chats] ([ChatId])
);
GO

CREATE NONCLUSTERED INDEX [IX_UserResponseQueue_Combination]
ON [dbo].[ChatResponseQueue] ([ChatId] ASC, [Processed] ASC)
INCLUDE ([ChatResponseQueueId])
WITH (ONLINE = ON);
GO
CREATE TABLE [dbo].[TextToSpeechQueue]
(
  [TtsId] INT IDENTITY(1, 1) NOT NULL,
  [ChatId] INT NOT NULL,
  [TtsStatus] VARCHAR(50) DEFAULT ('Queued'),
  [TtsCreatedTimestampUtc] DATETIME NOT NULL CONSTRAINT [DF_TextToSpeechQueue_TtsCreatedTimestampUtc] DEFAULT GETUTCDATE(),
  [TtsCompletedTimestampUtc] DATETIME NULL,
  [IsComplete] BIT NOT NULL CONSTRAINT [DF_TextToSpeechQueue_IsComplete] DEFAULT 0,
  CONSTRAINT [PK_TextToSpeechQueue_TtsId] PRIMARY KEY CLUSTERED ([TtsId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_TextToSpeechQueue_ChatId]
ON [dbo].[TextToSpeechQueue] ([ChatId] ASC)
INCLUDE ([TtsStatus], [TtsCreatedTimestampUtc], [TtsCompletedTimestampUtc], [IsComplete])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_TextToSpeechQueue_IsComplete]
ON [dbo].[TextToSpeechQueue] ([IsComplete] ASC)
INCLUDE ([TtsStatus], [TtsCreatedTimestampUtc], [TtsCompletedTimestampUtc])
WITH (ONLINE = ON);
GO

CREATE NONCLUSTERED INDEX [IX_TextToSpeechQueue_TtsStatus]
ON [dbo].[TextToSpeechQueue] ([TtsStatus] ASC)
INCLUDE ([ChatId], [TtsCreatedTimestampUtc], [TtsCompletedTimestampUtc], [IsComplete])
WITH (ONLINE = ON);
GO

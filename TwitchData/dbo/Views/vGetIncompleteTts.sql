CREATE VIEW [dbo].[vGetIncompleteTts]
WITH SCHEMABINDING
AS
SELECT u.UserId, u.UserName, t.TtsId, c.ChatId, c.ChatMessage, c.TimeStampUtc, t.TtsCreatedTimestampUtc
FROM dbo.TextToSpeechQueue t
INNER JOIN dbo.Chats c ON c.ChatId = t.ChatId
INNER JOIN dbo.Users u ON u.UserId = c.UserId
WHERE t.TtsStatus = 'Queued' AND t.IsComplete = 0;
GO
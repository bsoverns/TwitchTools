CREATE VIEW [dbo].[vGetIncompleteTts]
WITH SCHEMABINDING
AS
SELECT u.UserId, u.UserName, c.ChatId, c.ChatMessage, c.TimeStampUtc
FROM dbo.Chats c
INNER JOIN dbo.Users u ON u.UserId = c.UserId
WHERE c.IsTextToSpeech = 1 AND c.IsModerated = 1 AND c.IsFlagged = 0 AND c.IsTtsComplete = 0;
GO
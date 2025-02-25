CREATE VIEW [dbo].[vGetRecentConversation]
WITH SCHEMABINDING
AS
SELECT u.UserName, c.ChatMessage, c.TimeStampUtc AS [UserTimestamp], cb.ResponseMessage AS [BotResponseMessage], cb.TimeStampUtc AS [BotTimestamp]
FROM dbo.Chats c
INNER JOIN dbo.Users u ON u.UserId = c.UserId
INNER JOIN dbo.ChatBotResponse cb ON cb.ChatId = c.ChatId
WHERE ChannelName = 'bsoverns'
AND c.IsFlagged = 0 
AND c.TimeStampUtc >= DATEADD(MINUTE, -30, GETUTCDATE());
GO

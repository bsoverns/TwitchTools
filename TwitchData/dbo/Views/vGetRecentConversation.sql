CREATE VIEW [dbo].[vGetRecentConversation]
AS
SELECT u.UserName, c.ChatMessage, c.TimeStampUtc AS [UserTimestamp], cb.ResponseMessage AS [BotResponseMessage], cb.TimeStampUtc AS [BotTimestamp]
FROM dbo.Chats c WITH(NOLOCK)
INNER JOIN dbo.Users u WITH(NOLOCK) ON u.UserId = c.UserId
INNER JOIN dbo.ChatBotResponse cb WITH(NOLOCK) ON cb.ChatId = c.ChatId
WHERE ChannelName = 'bsoverns'
AND c.IsFlagged = 0 
AND c.TimeStampUtc >= DATEADD(MINUTE, -30, GETUTCDATE())
AND c.IsModerated = 1
AND c.IsTtsComplete = 1;
GO

CREATE VIEW [dbo].[vGetPendingBotChat]
AS 
SELECT c.ChatResponseQueueId, u.UserName, ch.ChatMessage, c.CreatedDateTimeUtc
FROM [dbo].[ChatResponseQueue] c WITH (NOLOCK)
INNER JOIN [dbo].[Chats] ch WITH(NOLOCK) ON ch.ChatId = c.ChatId
INNER JOIN [dbo].[Users] u WITH(NOLOCK) ON u.UserId = ch.UserId
WHERE c.[Processed] = 0 AND ch.IsModerated = 1 AND ch.IsTtsComplete = 1
GO
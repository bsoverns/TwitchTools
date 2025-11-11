CREATE VIEW [dbo].[vGetUncheckedChatsForModeration]
AS
SELECT ChatId, ChatMessage, TimeStampUtc
FROM dbo.Chats WITH(NOLOCK)
WHERE IsModerated = 0;
GO
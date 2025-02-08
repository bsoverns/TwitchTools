CREATE VIEW [dbo].[vGetUncheckedChatsForModeration]
WITH SCHEMABINDING
AS
SELECT ChatId, ChatMessage, TimeStampUtc
FROM dbo.Chats 
WHERE IsModerated = 0
AND ChannelName = 'bsoverns';
GO
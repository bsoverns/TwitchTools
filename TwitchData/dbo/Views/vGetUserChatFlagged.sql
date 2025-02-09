CREATE VIEW [dbo].[vGetUserChatFlagged]
WITH SCHEMABINDING
AS
SELECT u.UserId, u.UserName, c.ChatId, c.ChatMessage, c.ChannelName, c.TimeStampUtc, c.IsFlagged, c.FlaggedReason
FROM dbo.Chats c
INNER JOIN dbo.Users u ON u.UserId = c.UserId
AND c.IsFlagged = 1;
GO
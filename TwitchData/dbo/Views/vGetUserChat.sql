CREATE VIEW [dbo].[vGetUserChat]
AS
SELECT u.UserId, u.UserName, c.ChatId, c.ChatMessage, c.ChannelName, c.TimeStampUtc, c.IsFlagged, c.FlaggedReason
FROM dbo.Chats c WITH(NOLOCK)
INNER JOIN dbo.Users u WITH(NOLOCK) ON u.UserId = c.UserId;
GO
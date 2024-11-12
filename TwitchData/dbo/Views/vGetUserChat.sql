CREATE VIEW [dbo].[vGetUserChat]
WITH SCHEMABINDING
AS
SELECT u.UserId, u.UserName, c.ChatId, c.ChatMessage
FROM dbo.Chats c
INNER JOIN dbo.Users u ON u.UserId = c.UserId;
GO
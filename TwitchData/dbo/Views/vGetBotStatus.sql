CREATE VIEW [dbo].[vGetBotStatus]
AS
SELECT BotName, IsLive
FROM [dbo].[BotStatus] WITH(NOLOCK);
GO
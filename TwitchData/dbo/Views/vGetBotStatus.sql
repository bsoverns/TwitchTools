CREATE VIEW [dbo].[vGetBotStatus]
WITH SCHEMABINDING
AS
	SELECT BotName, IsLive
	FROM [dbo].[BotStatus];
GO
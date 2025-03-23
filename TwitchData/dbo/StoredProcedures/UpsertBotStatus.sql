CREATE PROCEDURE [dbo].[UpsertBotStatus]
(
    @BotName VARCHAR(50),
    @IsLive BIT = 0
)
AS
BEGIN
    DECLARE @CurrentTime DATETIME = GETUTCDATE();

    MERGE INTO dbo.BotStatus AS target
    USING 
	(
		SELECT @BotName AS BotName, @IsLive AS IsLive, @CurrentTime AS LastUpdated
	) AS source
    ON target.BotName = source.BotName

	WHEN MATCHED AND target.IsLive != source.IsLive THEN
		UPDATE SET target.IsLive = source.IsLive, target.LastUpdated = source.LastUpdated

	WHEN NOT MATCHED THEN
		INSERT (BotName, IsLive, LastUpdated)
		VALUES (source.BotName, source.IsLive, source.LastUpdated);    
END;
GO
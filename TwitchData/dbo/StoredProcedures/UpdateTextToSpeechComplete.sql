CREATE PROCEDURE [dbo].[UpdateTextToSpeechComplete]
	@ChatId INT
AS
BEGIN
	UPDATE dbo.Chats
	SET IsTtsComplete = 1, TtsCompletedTimestampUtc = GETUTCDATE()
	WHERE ChatId = @ChatId
	AND IsTtsComplete = 0;
END;
GO
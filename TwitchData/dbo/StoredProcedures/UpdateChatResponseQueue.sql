CREATE PROCEDURE [dbo].[UpdateChatResponseQueue]
(
	@ChatResponseQueueId INT
)
AS
BEGIN
	UPDATE [dbo].[ChatResponseQueue]
	SET Processed = 1,
		ProcessedDateTimeUtc = GETUTCDATE()
	WHERE ChatResponseQueueId = @ChatResponseQueueId;
END;
GO

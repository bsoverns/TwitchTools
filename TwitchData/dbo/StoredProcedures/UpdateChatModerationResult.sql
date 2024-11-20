CREATE PROCEDURE [dbo].[UpdateChatModerationResult]
	@ChatId INT,	
	@IsFlagged BIT,
	@FlaggedReason VARCHAR(500) = NULL
AS
BEGIN
	UPDATE dbo.Chats
	SET IsFlagged = @IsFlagged, FlaggedReason = @FlaggedReason, IsModerated = 1
	WHERE ChatId = @ChatId
	AND IsModerated = 0;	
END;
GO
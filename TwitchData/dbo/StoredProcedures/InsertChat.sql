CREATE PROCEDURE [dbo].[InsertChat]
(
	@UserId INT,
	@ChatMessage VARCHAR(500),
	@IsCommand BIT = NULL,
	@InteractionDateUtc DATETIME = NULL
)
AS
BEGIN
	DECLARE @ChatId INT;

	IF (@InteractionDateUtc IS NULL)
		SET @InteractionDateUtc = GETUTCDATE();

	INSERT INTO Chats (UserId, ChatMessage, TimeStampUtc, IsCommand)
	VALUES (@UserId, @ChatMessage, @InteractionDateUtc, @IsCommand);	

	SET @ChatId = SCOPE_IDENTITY();

	IF (@ChatId IS NULL)
		SELECT @ChatId = ChatId FROM Chats WHERE UserId = @UserId AND ChatMessage = @ChatMessage AND TimeStampUtc = @InteractionDateUtc;

	SELECT @ChatId;
END
GO
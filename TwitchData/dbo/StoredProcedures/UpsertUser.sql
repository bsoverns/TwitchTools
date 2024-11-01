CREATE PROCEDURE [dbo].[UpsertUser]
(
	@TwitchUserId VARCHAR(50) = NULL,
	@UserName VARCHAR(50),
	@InteractionDateUtc DATETIME NULL
)
AS
BEGIN
	DECLARE @UserId INT;
	
	IF (@InteractionDateUtc IS NULL)
		SET @InteractionDateUtc = GETUTCDATE();

	MERGE INTO [dbo].[Users] AS t
	USING 
	(
		SELECT @TwitchUserId AS TwitchUserId, @UserName AS UserName, @InteractionDateUtc AS InteractionDateUtc
	) AS s
	ON t.UserName = s.UserName
	WHEN MATCHED AND
	(
		ISNULL(t.TwitchUserId, '') <> ISNULL(t.TwitchUserId, '')
		OR 
		ISNULL(t.LastInteractionDateTimeUtc, '1900-01-01') != ISNULL(s.InteractionDateUtc, '1900-01-01')
	)	
	THEN
		UPDATE SET t.LastInteractionDateTimeUtc = @InteractionDateUtc
	WHEN NOT MATCHED THEN
		INSERT (TwitchUserId, UserName, FirstInteractionDateTimeUtc, LastInteractionDateTimeUtc)
		VALUES (s.TwitchUserId, s.UserName, @InteractionDateUtc, @InteractionDateUtc);

	SET @UserId = SCOPE_IDENTITY();
	IF (@UserId IS NULL)
		SELECT @UserId = UserId FROM [dbo].[Users] WHERE UserName = @UserName;

	SELECT @UserId;
END
GO
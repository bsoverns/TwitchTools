CREATE PROCEDURE [dbo].[InsertChat]
(
	@UserId INT = NULL,
	@TwitchUserId VARCHAR(50) = NULL,
	@UserName VARCHAR(50) = NULL,
	@ChatMessage VARCHAR(500),
	@IsCommand BIT = NULL,
	@InteractionDateUtc DATETIME = NULL,
	@ChatId INT NULL OUTPUT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'UserId, TwitchUserId, and UserName cannot be NULL.';				
				RETURN;
			END
	
			IF (@UserId IS NULL AND (@TwitchUserId IS NOT NULL OR @UserName IS NOT NULL))
			BEGIN
				IF (@TwitchUserId IS NULL OR @UserName IS NULL)		
				BEGIN
					EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'TwitchUserId and UserName cannot be NULL.';
				END							

				EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @InteractionDateUtc, @UserId = @UserId OUTPUT;

				IF (@UserId IS NULL)
				BEGIN
					EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'UserId cannot be NULL.';
					RETURN; 
				END
			END;

			IF (@InteractionDateUtc IS NULL)
				SET @InteractionDateUtc = GETUTCDATE();

			INSERT INTO Chats (UserId, ChatMessage, TimeStampUtc, IsCommand)
			VALUES (@UserId, @ChatMessage, @InteractionDateUtc, @IsCommand);	

			SET @ChatId = SCOPE_IDENTITY();

			IF (@ChatId IS NULL)
				SELECT @ChatId = ChatId FROM Chats WHERE UserId = @UserId AND ChatMessage = @ChatMessage AND TimeStampUtc = @InteractionDateUtc;;

			SELECT @ChatId;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', @ErrorMessage;
	END CATCH
END;
GO
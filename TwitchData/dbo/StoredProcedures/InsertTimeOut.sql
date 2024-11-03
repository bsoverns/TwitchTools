CREATE PROCEDURE [dbo].[InsertTimeout]
(
	@UserId INT = NULL,
	@TwitchUserId VARCHAR(50) = NULL,
	@UserName VARCHAR(50) = NULL,
	@TimeoutBy VARCHAR(50),
	@TimeoutReason VARCHAR(500),
	@TimeoutDurationInMinutes INT,
	@TimeoutTimestampUtc DATETIME = NULL,
	@TimeoutId INT NULL OUTPUT
)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
		BEGIN
			EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', 'UserId, TwitchUserId, and UserName cannot be NULL.';				
			RETURN;
		END

		IF (@UserId IS NULL AND (@TwitchUserId IS NOT NULL OR @UserName IS NOT NULL))
		BEGIN
			IF (@TwitchUserId IS NULL OR @UserName IS NULL)		
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', 'TwitchUserId and UserName cannot be NULL.';
			END							

			EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @TimeoutTimestampUtc, @UserId = @UserId OUTPUT;

			IF (@UserId IS NULL)
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', 'UserId cannot be NULL.';
				RETURN; 
			END
		END;

		IF (@TimeoutTimestampUtc IS NULL)
			SET @TimeoutTimestampUtc = GETUTCDATE();

		INSERT INTO Timeouts (UserId, TimeoutBy, TimeoutReason, TimeoutDurationInMinutes, TimeoutTimestampUtc)
		VALUES (@UserId, @TimeoutBy, @TimeoutReason, @TimeoutDurationInMinutes, @TimeoutTimestampUtc);

		SET @TimeoutId = SCOPE_IDENTITY();

		IF (@TimeoutId IS NULL)
			SELECT @TimeoutId = TimeoutId FROM Timeouts WHERE UserId = @UserId AND TimeoutBy = @TimeoutBy AND TimeoutReason = @TimeoutReason AND TimeoutDurationInMinutes = @TimeoutDurationInMinutes AND TimeoutTimestampUtc = @TimeoutTimestampUtc;

		SELECT @TimeoutId;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', @ErrorMessage;
	END CATCH
END
GO
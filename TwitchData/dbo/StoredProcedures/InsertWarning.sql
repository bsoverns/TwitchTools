CREATE PROCEDURE [dbo].[InsertWarning]
(
	@UserId INT = NULL,
	@TwitchUserId VARCHAR(50) = NULL,
	@UserName VARCHAR(50) = NULL,
	@WarnedBy VARCHAR(50),
	@WarningReason VARCHAR(500),
	@WarningTimestampUtc DATETIME = NULL,
	@WarningId INT NULL OUTPUT
)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION	
		IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
		BEGIN
			EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', 'UserId, TwitchUserId, and UserName cannot be NULL.';				
			RETURN;
		END

		IF (@UserId IS NULL AND (@TwitchUserId IS NOT NULL OR @UserName IS NOT NULL))
		BEGIN
			IF (@TwitchUserId IS NULL OR @UserName IS NULL)		
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', 'TwitchUserId and UserName cannot be NULL.';
			END							

			EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @WarningTimestampUtc, @UserId = @UserId OUTPUT;

			IF (@UserId IS NULL)
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', 'UserId cannot be NULL.';
				RETURN; 
			END
		END;

		IF (@WarningTimestampUtc IS NULL)
			SET @WarningTimestampUtc = GETUTCDATE();

		INSERT INTO Warnings (UserId, WarnedBy, WarningReason, WarningTimestampUtc)
		VALUES (@UserId, @WarnedBy, @WarningReason, @WarningTimestampUtc);

		SET @WarningId = SCOPE_IDENTITY();

		IF (@WarningId IS NULL)
			SELECT @WarningId = WarningId FROM Warnings WHERE UserId = @UserId AND WarnedBy = @WarnedBy AND WarningReason = @WarningReason AND WarningTimestampUtc = @WarningTimestampUtc;

		SELECT @WarningId;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', @ErrorMessage;
	END CATCH
END
GO
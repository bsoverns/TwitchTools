CREATE PROCEDURE [dbo].[InsertBan]
(
	@UserId INT = NULL,
	@TwitchUserId VARCHAR(50) = NULL,
	@UserName VARCHAR(50) = NULL,
	@BannedBy VARCHAR(50),	
	@BanReason VARCHAR(500),
	@BannedTimestampUtc DATETIME = NULL,
	@BanId INT NULL OUTPUT

)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
		IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
		BEGIN
			EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', 'UserId, TwitchUserId, and UserName cannot be NULL.';				
			RETURN;
		END

		IF (@UserId IS NULL AND (@TwitchUserId IS NOT NULL OR @UserName IS NOT NULL))
		BEGIN
			IF (@TwitchUserId IS NULL OR @UserName IS NULL)		
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', 'TwitchUserId and UserName cannot be NULL.';
			END							

			EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @BannedTimestampUtc, @UserId = @UserId OUTPUT;

			IF (@UserId IS NULL)
			BEGIN
				EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', 'UserId cannot be NULL.';
				RETURN; 
			END
		END;

		IF (@BannedTimestampUtc IS NULL)
			SET @BannedTimestampUtc = GETUTCDATE();

		INSERT INTO Bans (UserId, BannedBy, BannedReason, BannedTimestampUtc)
		VALUES (@UserId, @BannedBy, @BanReason, @BannedTimestampUtc);

		SET @BanId = SCOPE_IDENTITY();

		IF (@BanId IS NULL)
			SELECT @BanId = BanId FROM Bans WHERE UserId = @UserId AND BannedBy = @BannedBy AND BannedReason = @BanReason AND BannedTimestampUtc = @BannedTimestampUtc;

		SELECT @BanId;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', @ErrorMessage;
	END CATCH
END
GO

CREATE PROCEDURE [dbo].[InsertBan]
(
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @BannedBy VARCHAR(50),    
    @BanReason VARCHAR(500),
    @BannedTimestampUtc DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BanId INT;
        DECLARE @UserTable TABLE (UserId INT);

        IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
        BEGIN
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'UserId, TwitchUserId, and UserName cannot be NULL.';                
            RETURN;
        END

        IF (@TwitchUserId IS NULL AND @UserName IS NULL)
        BEGIN
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'TwitchUserId and UserName cannot be NULL.';
            RETURN; 
        END

        INSERT INTO @UserTable
        EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @BannedTimestampUtc;

        SELECT @UserId = UserId FROM @UserTable;

        IF (@BannedTimestampUtc IS NULL)
            SET @BannedTimestampUtc = GETUTCDATE();

        INSERT INTO Bans (UserId, BannedBy, BannedReason, BannedTimestampUtc)
        VALUES (@UserId, @BannedBy, @BanReason, @BannedTimestampUtc);

        SET @BanId = SCOPE_IDENTITY();

        SELECT @BanId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', @ErrorMessage;
    END CATCH
END
GO
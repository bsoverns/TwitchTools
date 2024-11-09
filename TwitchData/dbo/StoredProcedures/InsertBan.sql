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

    IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', 'UserId, TwitchUserId, and UserName cannot all be NULL.';                
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@UserId IS NULL)
        BEGIN
            EXEC [dbo].[UpsertUser] 
                @TwitchUserId = @TwitchUserId, 
                @UserName = @UserName, 
                @InteractionDateUtc = @BannedTimestampUtc, 
                @UserId = @UserId OUTPUT;

            IF (@UserId IS NULL)
            BEGIN
                EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', 'Failed to upsert user. UserId cannot be NULL.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        IF (@BannedTimestampUtc IS NULL)
            SET @BannedTimestampUtc = GETUTCDATE();

        DECLARE @BanId INT;
        INSERT INTO Bans (UserId, BannedBy, BannedReason, BannedTimestampUtc)
        VALUES (@UserId, @BannedBy, @BanReason, @BannedTimestampUtc);

        SET @BanId = SCOPE_IDENTITY();

        SELECT @BanId AS BanId;

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
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertBan', @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

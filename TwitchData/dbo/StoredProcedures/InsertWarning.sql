CREATE PROCEDURE [dbo].[InsertWarning]
(
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @WarnedBy VARCHAR(50),
    @WarningReason VARCHAR(500),
    @WarningTimestampUtc DATETIME = NULL    
)
AS
BEGIN
    SET NOCOUNT ON;
    
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
    EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @WarningTimestampUtc;

    SELECT @UserId = UserId FROM @UserTable;
    
    BEGIN TRY
        BEGIN TRANSACTION    
            DECLARE @WarningId INT;

            IF (@WarningTimestampUtc IS NULL)
                SET @WarningTimestampUtc = GETUTCDATE();

            INSERT INTO Warnings (UserId, WarnedBy, WarningReason, WarningTimestampUtc)
            VALUES (@UserId, @WarnedBy, @WarningReason, @WarningTimestampUtc);

            SET @WarningId = SCOPE_IDENTITY();

            -- Return the WarningId directly
            SELECT @WarningId;
        COMMIT TRANSACTION
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
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', @ErrorMessage;
    END CATCH
END
GO

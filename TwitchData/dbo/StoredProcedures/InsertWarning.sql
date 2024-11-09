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

    -- Validate input parameters
    IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', 'UserId, TwitchUserId, and UserName cannot all be NULL.';                
        RETURN;
    END

    IF (@UserId IS NULL)
    BEGIN
        EXEC [dbo].[UpsertUser] 
            @TwitchUserId = @TwitchUserId, 
            @UserName = @UserName, 
            @InteractionDateUtc = @WarningTimestampUtc, 
            @UserId = @UserId OUTPUT;

        IF (@UserId IS NULL)
        BEGIN
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', 'Failed to upsert user. UserId cannot be NULL.';
            RETURN;
        END
    END

    IF (@WarningTimestampUtc IS NULL)
        SET @WarningTimestampUtc = GETUTCDATE();

    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @WarningId INT;

        -- Insert warning record
        INSERT INTO Warnings (UserId, WarnedBy, WarningReason, WarningTimestampUtc)
        VALUES (@UserId, @WarnedBy, @WarningReason, @WarningTimestampUtc);

        SET @WarningId = SCOPE_IDENTITY();

        SELECT @WarningId AS WarningId;

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
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertWarning', @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE PROCEDURE [dbo].[InsertTimeout]
(
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @TimeoutBy VARCHAR(50),
    @TimeoutReason VARCHAR(500),
    @TimeoutDurationInMinutes INT,
    @TimeoutTimestampUtc DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', 'UserId, TwitchUserId, and UserName cannot all be NULL.';                
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@UserId IS NULL)
        BEGIN
            EXEC [dbo].[UpsertUser] 
                @TwitchUserId = @TwitchUserId, 
                @UserName = @UserName, 
                @InteractionDateUtc = @TimeoutTimestampUtc, 
                @UserId = @UserId OUTPUT;

            IF (@UserId IS NULL)
            BEGIN
                EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', 'Failed to upsert user. UserId cannot be NULL.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        IF (@TimeoutTimestampUtc IS NULL)
            SET @TimeoutTimestampUtc = GETUTCDATE();
                    
        DECLARE @TimeoutId INT;
        INSERT INTO Timeouts (UserId, TimeoutBy, TimeoutReason, TimeoutDurationInMinutes, TimeoutTimestampUtc)
        VALUES (@UserId, @TimeoutBy, @TimeoutReason, @TimeoutDurationInMinutes, @TimeoutTimestampUtc);

        SET @TimeoutId = SCOPE_IDENTITY();

        SELECT @TimeoutId AS TimeoutId;

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
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

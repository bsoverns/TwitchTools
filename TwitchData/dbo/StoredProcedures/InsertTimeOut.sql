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

    BEGIN TRY
        -- Begin the transaction for the core operation only
        BEGIN TRANSACTION;

        DECLARE @TimeoutId INT;
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
        EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @TimeoutTimestampUtc;

        SELECT @UserId = UserId FROM @UserTable;

        IF (@TimeoutTimestampUtc IS NULL)
            SET @TimeoutTimestampUtc = GETUTCDATE();

        -- Insert into Timeouts
        INSERT INTO Timeouts (UserId, TimeoutBy, TimeoutReason, TimeoutDurationInMinutes, TimeoutTimestampUtc)
        VALUES (@UserId, @TimeoutBy, @TimeoutReason, @TimeoutDurationInMinutes, @TimeoutTimestampUtc);

        SET @TimeoutId = SCOPE_IDENTITY();

        -- If TimeoutId is null, use an alternative lookup
        IF (@TimeoutId IS NULL)
            SELECT @TimeoutId = TimeoutId 
            FROM Timeouts 
            WHERE UserId = @UserId 
                AND TimeoutBy = @TimeoutBy 
                AND TimeoutReason = @TimeoutReason 
                AND TimeoutDurationInMinutes = @TimeoutDurationInMinutes 
                AND TimeoutTimestampUtc = @TimeoutTimestampUtc;

        -- Return the TimeoutId
        SELECT @TimeoutId;

        -- Commit the transaction after successful operations
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Instead of rolling back, handle the error more gracefully
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Capture and raise the error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertTimeout', @ErrorMessage;
    END CATCH
END;
GO
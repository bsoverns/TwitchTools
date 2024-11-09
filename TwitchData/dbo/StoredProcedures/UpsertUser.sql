CREATE PROCEDURE [dbo].[UpsertUser] 
(
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50),
    @InteractionDateUtc DATETIME = NULL,
    @UserId INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@UserName IS NULL)
        BEGIN
            EXEC [dbo].[InsertErrorTrackInfo] 'UpsertUser', 'UserName cannot be NULL.';                
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF (@InteractionDateUtc IS NULL)
            SET @InteractionDateUtc = GETUTCDATE();

        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserName = @UserName)
        BEGIN
            UPDATE [dbo].[Users]
            SET 
                LastInteractionDateTimeUtc = @InteractionDateUtc,
                TwitchUserId = COALESCE(@TwitchUserId, TwitchUserId)
            WHERE UserName = @UserName;

            SELECT @UserId = UserId 
            FROM [dbo].[Users] 
            WHERE UserName = @UserName;
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[Users] (TwitchUserId, UserName, FirstInteractionDateTimeUtc, LastInteractionDateTimeUtc)
            VALUES (@TwitchUserId, @UserName, @InteractionDateUtc, @InteractionDateUtc);

            SET @UserId = SCOPE_IDENTITY();
        END

        SELECT @UserId AS UserId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        EXEC [dbo].[InsertErrorTrackInfo] 'UpsertUser', @ErrorMessage;
    END CATCH
END;
GO

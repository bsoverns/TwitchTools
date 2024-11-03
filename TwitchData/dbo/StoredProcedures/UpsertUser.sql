CREATE PROCEDURE [dbo].[UpsertUser]
(
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50),
    @InteractionDateUtc DATETIME NULL,
    @UserId INT NULL OUTPUT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF (@UserName IS NULL)
            BEGIN
                EXEC [dbo].[InsertErrorTrackInfo] 'UpsertUser', 'UserName cannot be NULL.';                
                RETURN;
            END
                    
            IF (@InteractionDateUtc IS NULL)
                SET @InteractionDateUtc = GETUTCDATE();

            DECLARE @UserTable TABLE (UserId INT);

            MERGE INTO [dbo].[Users] AS t
            USING 
            (
                SELECT @TwitchUserId AS TwitchUserId, @UserName AS UserName, @InteractionDateUtc AS InteractionDateUtc
            ) AS s
            ON t.UserName = s.UserName
            WHEN MATCHED AND
            (
                ISNULL(t.TwitchUserId, '') <> ISNULL(t.TwitchUserId, '') OR 
                ISNULL(t.LastInteractionDateTimeUtc, '1900-01-01') != ISNULL(s.InteractionDateUtc, '1900-01-01')
            )   
            THEN
                UPDATE SET 
                    t.LastInteractionDateTimeUtc = @InteractionDateUtc,
                    t.TwitchUserId = ISNULL(t.TwitchUserId, s.TwitchUserId)
            WHEN NOT MATCHED THEN
                INSERT (TwitchUserId, UserName, FirstInteractionDateTimeUtc, LastInteractionDateTimeUtc)
                VALUES (s.TwitchUserId, s.UserName, @InteractionDateUtc, @InteractionDateUtc)
            OUTPUT inserted.UserId INTO @UserTable;

            SELECT @UserId = UserId FROM @UserTable;

            IF (@UserId IS NULL)
                SELECT @UserId = UserId FROM [dbo].[Users] WHERE UserName = @UserName;

            SELECT @UserId;
        COMMIT TRANSACTION
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
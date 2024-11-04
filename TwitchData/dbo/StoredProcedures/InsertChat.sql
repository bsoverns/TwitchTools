CREATE PROCEDURE [dbo].[InsertChat]
(
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @ChatMessage VARCHAR(500),
    @IsCommand BIT = NULL,
    @InteractionDateUtc DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChatId INT;
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
    EXEC [dbo].[UpsertUser] @TwitchUserId = @TwitchUserId, @UserName = @UserName, @InteractionDateUtc = @InteractionDateUtc;

    SELECT @UserId = UserId FROM @UserTable;

    IF (@UserId IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'UserId cannot be NULL.';
        RETURN;
    END

    IF (@InteractionDateUtc IS NULL)
        SET @InteractionDateUtc = GETUTCDATE();

    BEGIN TRY
        INSERT INTO Chats (UserId, ChatMessage, TimeStampUtc, IsCommand)
        VALUES (@UserId, @ChatMessage, @InteractionDateUtc, @IsCommand);

        SET @ChatId = SCOPE_IDENTITY();

        SELECT @ChatId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', @ErrorMessage;
    END CATCH
END;
GO

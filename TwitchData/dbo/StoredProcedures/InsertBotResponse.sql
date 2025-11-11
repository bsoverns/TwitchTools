CREATE PROCEDURE [dbo].[InsertBotResponse]
( 
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @ChatMessage VARCHAR(500),
    @ChatBotResponse VARCHAR(500),
    @InteractionDateUtc DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChatId INT,
        @ChatBotResponseId INT;

    IF (@UserName IS NULL AND @ChatMessage IS NULL AND @ChatBotResponse IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertBotResponse', 'UserName, ChatMessage, and ChatResponse cannot all be NULL.';                
        RETURN;
    END

    IF (@UserId IS NULL)
    BEGIN
        EXEC [dbo].[UpsertUser] 
            @TwitchUserId = @TwitchUserId, 
            @UserName = @UserName, 
            @InteractionDateUtc = @InteractionDateUtc, 
            @UserId = @UserId OUTPUT;

        IF (@UserId IS NULL)
        BEGIN
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertBotResponse', 'Failed to upsert user. UserId cannot be NULL.';
            RETURN;
        END
    END
        
    BEGIN
        SET @ChatId = (SELECT TOP 1 ChatId FROM dbo.Chats WHERE UserId = @UserId AND ChatMessage = @ChatMessage ORDER BY TimeStampUtc DESC);

        IF (@ChatId IS NULL)
        BEGIN
            DECLARE @Error VARCHAR(100) = (SELECT 'Failed to find the correct ChatId for ' + @ChatMessage + '.'); 
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertBotResponse', @Error;
            RETURN;
        END
    END

    BEGIN TRY
        INSERT INTO ChatBotResponse (ChatId, ResponseMessage)
        VALUES (@ChatId, @ChatBotResponse);

        SET @ChatBotResponseId = SCOPE_IDENTITY();

        SELECT @ChatBotResponseId AS ChatBotResponseId;
    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT = ERROR_SEVERITY(),
            @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

        EXEC [dbo].[InsertErrorTrackInfo] 'InsertBotResponse', @ErrorMessage;
    END CATCH
END;
GO
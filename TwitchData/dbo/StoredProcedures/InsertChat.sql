﻿CREATE PROCEDURE [dbo].[InsertChat]
(
    @UserId INT = NULL,
    @TwitchUserId VARCHAR(50) = NULL,
    @UserName VARCHAR(50) = NULL,
    @ChatMessage VARCHAR(500),
    @ChannelName VARCHAR(50) = NULL,
    @IsCommand BIT = NULL,
    @InteractionDateUtc DATETIME = NULL,
    @IsTextToSpeech BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChatId INT;

    IF (@UserId IS NULL AND @TwitchUserId IS NULL AND @UserName IS NULL)
    BEGIN
        EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'UserId, TwitchUserId, and UserName cannot all be NULL.';                
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
            EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', 'Failed to upsert user. UserId cannot be NULL.';
            RETURN;
        END
    END

    IF (@InteractionDateUtc IS NULL)
        SET @InteractionDateUtc = GETUTCDATE();

    BEGIN TRY
        INSERT INTO Chats (UserId, ChatMessage, ChannelName, TimeStampUtc, IsCommand, IsTextToSpeech)
        VALUES (@UserId, @ChatMessage, @ChannelName, @InteractionDateUtc, @IsCommand, @IsTextToSpeech);

        SET @ChatId = SCOPE_IDENTITY();

        SELECT @ChatId AS ChatId;
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

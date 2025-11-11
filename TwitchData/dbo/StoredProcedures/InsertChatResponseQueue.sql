CREATE PROCEDURE [dbo].[InsertChatResponseQueue]
(
    @ChatId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChatResponseQueueId INT;

    IF (@ChatId IS NOT NULL)
    BEGIN 
        BEGIN TRY
            INSERT INTO [dbo].[ChatResponseQueue] (ChatId)
            VALUES (@ChatId);

            SET @ChatResponseQueueId = SCOPE_IDENTITY();

            SELECT @ChatResponseQueueId AS ChatResponseQueueId
        END TRY
        BEGIN CATCH
            DECLARE 
                @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

            EXEC [dbo].[InsertErrorTrackInfo] 'InsertChat', @ErrorMessage;
        END CATCH
    END
END;
GO

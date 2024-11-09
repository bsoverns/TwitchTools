CREATE PROCEDURE [dbo].[InsertTextToSpeechQueue]
(
	@ChatId INT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
			DECLARE @TtsId INT;

			INSERT INTO [dbo].[TextToSpeechQueue] ([ChatId])
			VALUES (@ChatId);

			SET @TtsId = SCOPE_IDENTITY();

			SELECT @TtsId AS TtsId;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertTextToSpeechQueue', @ErrorMessage;
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END;
GO

CREATE PROCEDURE [dbo].[InsertTextToSpeechQueue]
(
	@ChatId INT,
	@TtsId INT NULL OUTPUT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			INSERT INTO [dbo].[TextToSpeechQueue] ([ChatId])
			VALUES (@ChatId);

			SET @TtsId = SCOPE_IDENTITY();

			IF (@TtsId IS NULL)
				SELECT @TtsId = TtsId FROM [dbo].[TextToSpeechQueue] WHERE ChatId = @ChatId;

			SELECT @TtsId;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		-- Capture error details
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		EXEC [dbo].[InsertErrorTrackInfo] 'InsertTts', @ErrorMessage;
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END;
GO
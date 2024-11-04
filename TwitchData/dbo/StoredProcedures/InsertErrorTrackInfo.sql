CREATE PROCEDURE [dbo].[InsertErrorTrackInfo]
(
	@ProcessName VARCHAR(50),
	@ErrorDescription VARCHAR(500) = NULL
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		BEGIN TRANSACTION
			DECLARE @ErrorTrackInfoId INT;

			IF (@ProcessName IS NULL)
				THROW 51000, 'ProcessName cannot be NULL.', 1;

			IF (@ErrorDescription IS NULL)
				THROW 51000, 'ErrorDescription cannot be NULL.', 1;

			INSERT INTO ErrorTrackInfo (ProcessName, ErrorDescription)
			VALUES (@ProcessName, @ErrorDescription);

			SET @ErrorTrackInfoId = SCOPE_IDENTITY();

			SELECT @ErrorTrackInfoId;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END;
GO
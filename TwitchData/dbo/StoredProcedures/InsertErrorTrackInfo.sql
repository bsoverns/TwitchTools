CREATE PROCEDURE [dbo].[InsertErrorTrackInfo]
(
	@ProcessName VARCHAR(50),
	@ErrorDescription VARCHAR(500) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@ProcessName IS NULL)
    BEGIN
        RAISERROR('ProcessName cannot be NULL.', 16, 1);
        RETURN;
    END

    IF (@ErrorDescription IS NULL)
    BEGIN
        RAISERROR('ErrorDescription cannot be NULL.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ErrorTrackInfoId INT;

        INSERT INTO ErrorTrackInfo (ProcessName, ErrorDescription)
        VALUES (@ProcessName, @ErrorDescription);

        SET @ErrorTrackInfoId = SCOPE_IDENTITY();

        SELECT @ErrorTrackInfoId AS ErrorTrackInfoId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT = ERROR_SEVERITY(),
            @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

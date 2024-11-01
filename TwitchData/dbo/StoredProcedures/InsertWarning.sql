CREATE PROCEDURE [dbo].[InsertWarning]
(
	@UserId INT,
	@WarnedBy VARCHAR(50),
	@WarningReason VARCHAR(500),
	@WarningTimestampUtc DATETIME = NULL
)
AS
BEGIN
	DECLARE @WarningId INT;

	IF (@WarningTimestampUtc IS NULL)
		SET @WarningTimestampUtc = GETUTCDATE();

	INSERT INTO Warnings (UserId, WarnedBy, WarningReason, WarningTimestampUtc)
	VALUES (@UserId, @WarnedBy, @WarningReason, @WarningTimestampUtc);

	SET @WarningId = SCOPE_IDENTITY();

	IF (@WarningId IS NULL)
		SELECT @WarningId = WarningId FROM Warnings WHERE UserId = @UserId AND WarnedBy = @WarnedBy AND WarningReason = @WarningReason AND WarningTimestampUtc = @WarningTimestampUtc;

	SELECT @WarningId;
END
GO
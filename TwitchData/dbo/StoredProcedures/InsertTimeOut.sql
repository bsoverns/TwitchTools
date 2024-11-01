CREATE PROCEDURE [dbo].[InsertTimeOut]
(
	@UserId INT,
	@TimeOutBy VARCHAR(50),
	@TimeOutReason VARCHAR(500),
	@TimeoutDurationInMinutes INT,
	@TimeOutTimestampUtc DATETIME = NULL
)
AS
BEGIN
	DECLARE @TimeOutId INT;

	IF (@TimeOutTimestampUtc IS NULL)
		SET @TimeOutTimestampUtc = GETUTCDATE();

	INSERT INTO TimeOuts (UserId, TimeOutBy, TimeOutReason, TimeoutDurationInMinutes, TimeOutTimestampUtc)
	VALUES (@UserId, @TimeOutBy, @TimeOutReason, @TimeoutDurationInMinutes, @TimeOutTimestampUtc);

	SET @TimeOutId = SCOPE_IDENTITY();

	IF (@TimeOutId IS NULL)
		SELECT @TimeOutId = TimeOutId FROM TimeOuts WHERE UserId = @UserId AND TimeOutBy = @TimeOutBy AND TimeOutReason = @TimeOutReason AND TimeoutDurationInMinutes = @TimeoutDurationInMinutes AND TimeOutTimestampUtc = @TimeOutTimestampUtc;

	SELECT @TimeOutId;
END
GO
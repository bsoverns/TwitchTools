CREATE PROCEDURE [dbo].[InsertBan]
(
	@UserId INT,
	@BannedBy VARCHAR(50),	
	@BanReason VARCHAR(500),
	@BannedTimestampUtc DATETIME = NULL
)
AS
BEGIN
	DECLARE @BanId INT;

	IF (@BannedTimestampUtc IS NULL)
		SET @BannedTimestampUtc = GETUTCDATE();

	INSERT INTO Bans (UserId, BannedBy, BannedReason, BannedTimestampUtc)
	VALUES (@UserId, @BannedBy, @BanReason, @BannedTimestampUtc);

	SET @BanId = SCOPE_IDENTITY();

	IF (@BanId IS NULL)
		SELECT @BanId = BanId FROM Bans WHERE UserId = @UserId AND BannedBy = @BannedBy AND BannedReason = @BanReason AND BannedTimestampUtc = @BannedTimestampUtc;

	SELECT @BanId;	
END
GO

/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertBan stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertBan UnitTest for UserId - STARTED');

	DECLARE 
		@BanId INT = NULL,
		@TestUserId INT = 1,			
		@TestBannedBy VARCHAR(50) = 'bsoverns',
		@TestBanReason VARCHAR(500) = 'This is a test ban for UserId',
		@TestBannedTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertBan] 
		@UserId = @TestUserId, 
		@BannedBy = @TestBannedBy, 
		@BanReason = @TestBanReason, 
		@BannedTimestampUtc = @TestBannedTimestampUtc;

	SELECT TOP 1 @BanId = BanId 
	FROM [dbo].[Bans]
	WHERE 
		UserId = @TestUserId
		AND BannedBy = @TestBannedBy
		AND BannedReason = @TestBanReason
		AND BannedTimestampUtc = @TestBannedTimestampUtc
	ORDER BY BannedTimestampUtc DESC;

	IF (@BanId IS NULL)
		PRINT ('Fail: Ban was not created for UserId test case');
	ELSE
		PRINT ('Pass: Ban was created for UserId test case');

	PRINT('Running InsertBan UnitTest for UserId - COMPLETED');
END;
GO

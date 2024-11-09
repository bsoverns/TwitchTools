/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertBan stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertBan UnitTest for UserName - STARTED');

	DECLARE 
		@BanId INT = NULL,
		@TestTwitchUserId VARCHAR(50) = NULL,
		@TestUserName VARCHAR(50) = 'TestUserBan',
		@TestBannedBy VARCHAR(50) = 'bsoverns',
		@TestBanReason VARCHAR(500) = 'This is a test ban for UserName',
		@TestBannedTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertBan] 
		@TwitchUserId = @TestTwitchUserId, 
		@UserName = @TestUserName, 
		@BannedBy = @TestBannedBy, 
		@BanReason = @TestBanReason, 
		@BannedTimestampUtc = @TestBannedTimestampUtc;

	SELECT TOP 1 @BanId = BanId 
	FROM [dbo].[Bans]
	WHERE 
		UserId = (SELECT TOP 1 UserId FROM [dbo].[Users] WHERE (TwitchUserId = @TestTwitchUserId OR @TestTwitchUserId IS NULL) AND UserName = @TestUserName)
		AND BannedBy = @TestBannedBy
		AND BannedReason = @TestBanReason
		AND BannedTimestampUtc = @TestBannedTimestampUtc
	ORDER BY BannedTimestampUtc DESC;

	IF (@BanId IS NULL)
		PRINT ('Fail: Ban was not created for UserName test case');
	ELSE
		PRINT ('Pass: Ban was created for UserName test case');

	PRINT('Running InsertBan UnitTest for UserName - COMPLETED');
END;
GO

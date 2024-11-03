/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertBan stored procedure.
*  Created on: 2024--02
*  Last Modified on: 2024--02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	DECLARE @BanId INT,
		@TestTwitchUserId VARCHAR(50) = '234567894',
		@TestUserName VARCHAR(50) = 'TestUserBan',
		@TestBannedBy VARCHAR(50) = 'bsoverns',
		@TestBanReason VARCHAR(500) = 'This is a test ban for UserName',
		@TestBannedTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertBan] @TwitchUserId = @TestTwitchUserId, @UserName = @TestUserName, @BannedBy = @TestBannedBy, @BanReason = @TestBanReason, @BannedTimestampUtc = @TestBannedTimestampUtc, @BanId = @BanId OUTPUT;

	IF (@BanId IS NULL)
		PRINT ('Fail: Ban was not created for UserName test case');

	ELSE
		PRINT ('Pass: Ban was created for UserName test case');
END;
GO
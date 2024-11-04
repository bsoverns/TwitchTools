/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertBan stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	DECLARE @BanId INT,
		@TestUserId INT = 1,			
		@TestBannedBy VARCHAR(50) = 'bsoverns',
		@TestBanReason VARCHAR(500) = 'This is a test ban for UserId',
		@TestBannedTimestampUtc DATETIME = GETUTCDATE();

	DECLARE @Result TABLE (BanId INT);

	INSERT INTO @Result
	EXEC [dbo].[InsertBan] @UserId = @TestUserId, @BannedBy = @TestBannedBy, @BanReason = @TestBanReason, @BannedTimestampUtc = @TestBannedTimestampUtc;

	SELECT @BanId = BanId FROM @Result;

	IF (@BanId IS NULL)
		PRINT ('Fail: Ban was not created for UserId test case');

	ELSE
		PRINT ('Pass: Ban was created for UserId test case');
END;
GO
/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertWarning stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	DECLARE @WarningId INT,
		@TestTwitchUserId NVARCHAR(255) = '1234567892',
		@TestUserName NVARCHAR(255) = 'TestUserWarning',
		@TestChatMessage VARCHAR(500) = 'This is a test message on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestWarnedBy VARCHAR(50) = 'bsoverns',
		@TestWarningReason VARCHAR(500) = 'This is a test warning for UserName',
		@TestWarningTimestampUtc DATETIME = GETUTCDATE();
	DECLARE @Result TABLE (WarningId INT);

	INSERT INTO @Result
	EXEC [dbo].[InsertWarning] @TwitchUserId = @TestTwitchUserId, @UserName = @TestUserName, @WarnedBy = @TestWarnedBy, @WarningReason = @TestWarningReason, @WarningTimestampUtc = @TestWarningTimestampUtc;

	SELECT @WarningId = WarningId FROM @Result;

	IF (@WarningId IS NULL)
		PRINT ('Fail: Warning was not created for UserName test case');

	ELSE
		PRINT ('Pass: Warning was created for UserName test case');
END;
GO
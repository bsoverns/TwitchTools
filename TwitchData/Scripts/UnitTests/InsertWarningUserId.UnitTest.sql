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
		@TestUserId INT = 1,
		@TestChatMessage VARCHAR(500) = 'This is a test message on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestWarnedBy VARCHAR(50) = 'bsoverns',
		@TestWarningReason VARCHAR(500) = 'This is a test warning for UserId',
		@TestWarningTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertWarning] @UserId = @TestUserId, @WarnedBy = @TestWarnedBy, @WarningReason = @TestWarningReason, @WarningTimestampUtc = @TestWarningTimestampUtc, @WarningId = @WarningId OUTPUT;

	IF (@WarningId IS NULL)
		PRINT ('Fail: Warning was not created for UserId test case');

	ELSE
		PRINT ('Pass: Warning was created for UserId test case');
END;
GO
/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertWarning stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertWarning UnitTest for UserName - STARTED');

	DECLARE 
		@WarningId INT = NULL,
		@TestTwitchUserId NVARCHAR(255) = NULL,
		@TestUserName NVARCHAR(255) = 'TestUserWarning',
		@TestWarnedBy VARCHAR(50) = 'bsoverns',
		@TestWarningReason VARCHAR(500) = 'This is a test warning for UserName',
		@TestWarningTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertWarning] 
		@TwitchUserId = @TestTwitchUserId, 
		@UserName = @TestUserName, 
		@WarnedBy = @TestWarnedBy, 
		@WarningReason = @TestWarningReason, 
		@WarningTimestampUtc = @TestWarningTimestampUtc;

	SELECT TOP 1 @WarningId = WarningId 
	FROM [dbo].[Warnings]
	WHERE 
		UserId = (SELECT TOP 1 UserId FROM [dbo].[Users] WHERE (TwitchUserId = @TestTwitchUserId OR @TestTwitchUserId IS NULL) AND UserName = @TestUserName)
		AND WarnedBy = @TestWarnedBy
		AND WarningReason = @TestWarningReason
		AND WarningTimestampUtc = @TestWarningTimestampUtc
	ORDER BY WarningTimestampUtc DESC;

	IF (@WarningId IS NULL)
		PRINT ('Fail: Warning was not created for UserName test case');
	ELSE
		PRINT ('Pass: Warning was created for UserName test case');

	PRINT('Running InsertWarning UnitTest for UserName - COMPLETED');
END;
GO
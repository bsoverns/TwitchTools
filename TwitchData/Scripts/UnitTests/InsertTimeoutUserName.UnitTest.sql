/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertTimeout stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertTimeout UnitTest for UserName - STARTED');

	DECLARE 
		@TimeoutId INT = NULL,
		@TestTwitchUserId VARCHAR(50) = NULL,
		@TestUserName VARCHAR(50) = 'TestUserTimeout',
		@TestTimeoutBy VARCHAR(50) = 'bsoverns',
		@TestTimeoutReason VARCHAR(500) = 'This is a test timeout UserName',
		@TestTimeoutDurationInMinutes INT = 1,
		@TestTimeoutTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertTimeout] 
		@TwitchUserId = @TestTwitchUserId, 
		@UserName = @TestUserName, 
		@TimeoutBy = @TestTimeoutBy, 
		@TimeoutReason = @TestTimeoutReason, 
		@TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes, 
		@TimeoutTimestampUtc = @TestTimeoutTimestampUtc;

	SELECT TOP 1 @TimeoutId = TimeoutId 
	FROM [dbo].[Timeouts]
	WHERE 
		UserId = (SELECT TOP 1 UserId FROM [dbo].[Users] WHERE (TwitchUserId = @TestTwitchUserId OR @TestTwitchUserId IS NULL) AND UserName = @TestUserName)
		AND TimeoutBy = @TestTimeoutBy
		AND TimeoutReason = @TestTimeoutReason
		AND TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes
		AND TimeoutTimestampUtc = @TestTimeoutTimestampUtc
	ORDER BY TimeoutTimestampUtc DESC;

	IF (@TimeoutId IS NULL)
		PRINT ('Fail: Timeout was not created for UserName test case');
	ELSE
		PRINT ('Pass: Timeout was created for UserName test case');

	PRINT('Running InsertTimeout UnitTest for UserName - COMPLETED');
END;
GO

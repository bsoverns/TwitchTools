/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertTimeout stored procedure.
*  Created on: 2024--02
*  Last Modified on: 2024--02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	
	DECLARE @TimeoutId INT,
		@TestTwitchUserId VARCHAR(50) = '234567893',
		@TestUserName VARCHAR(50) = 'TestUserTimeout',
		@TestTimeoutBy VARCHAR(50) = 'bsoverns',
		@TestTimeoutReason VARCHAR(500) = 'This is a test timeout UserName',
		@TestTimeoutDurationInMinutes INT = 1,
		@TestTimeoutTimestampUtc DATETIME = GETUTCDATE();
	DECLARE @Result TABLE (TimeoutId INT);

	INSERT INTO @Result
	EXEC [dbo].[InsertTimeout] @TwitchUserId = @TestTwitchUserId, @UserName = @TestUserName, @TimeoutBy = @TestTimeoutBy, @TimeoutReason = @TestTimeoutReason, @TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes, @TimeoutTimestampUtc = @TestTimeoutTimestampUtc;

	SELECT @TimeoutId = TimeoutId FROM @Result;

	IF (@TimeoutId IS NULL)
		PRINT ('Fail: Timeout was not created for UserName test case');

	ELSE
		PRINT ('Pass: Timeout was created for UserName test case');
END;
GO
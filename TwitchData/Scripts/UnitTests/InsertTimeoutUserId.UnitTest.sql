/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertTimeout stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	DECLARE @TimeoutId INT,
		@TestUserId INT = 1,			
		@TestTimeoutBy VARCHAR(50) = 'bsoverns',
		@TestTimeoutReason VARCHAR(500) = 'This is a test timeout for UserId',
		@TestTimeoutDurationInMinutes INT = 1,
		@TestTimeoutTimestampUtc DATETIME = GETUTCDATE();
	DECLARE @Result TABLE (TimeoutId INT);

	INSERT INTO @Result
	EXEC [dbo].[InsertTimeout] @UserId = @TestUserId, @TimeoutBy = @TestTimeoutBy, @TimeoutReason = @TestTimeoutReason, @TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes;

	SELECT @TimeoutId = TimeoutId FROM @Result;

	IF (@TimeoutId IS NULL)
		PRINT ('Fail: Timeout was not created for UserId test case');

	ELSE
		PRINT ('Pass: Timeout was created for UserId test case');
END;
GO
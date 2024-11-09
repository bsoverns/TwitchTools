/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertTimeout stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertTimeout UnitTest - STARTED');

	DECLARE 
		@TimeoutId INT = NULL,
		@TestUserId INT = 1,			
		@TestTimeoutBy VARCHAR(50) = 'bsoverns',
		@TestTimeoutReason VARCHAR(500) = 'This is a test timeout for UserId',
		@TestTimeoutDurationInMinutes INT = 1,
		@TestTimeoutTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[InsertTimeout] 
		@UserId = @TestUserId, 
		@TimeoutBy = @TestTimeoutBy, 
		@TimeoutReason = @TestTimeoutReason, 
		@TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes, 
		@TimeoutTimestampUtc = @TestTimeoutTimestampUtc;

	SELECT TOP 1 @TimeoutId = TimeoutId 
	FROM [dbo].[Timeouts]
	WHERE 
		UserId = @TestUserId
		AND TimeoutBy = @TestTimeoutBy
		AND TimeoutReason = @TestTimeoutReason
		AND TimeoutDurationInMinutes = @TestTimeoutDurationInMinutes
		AND TimeoutTimestampUtc = @TestTimeoutTimestampUtc
	ORDER BY TimeoutTimestampUtc DESC;

	IF (@TimeoutId IS NULL)
		PRINT ('Fail: Timeout was not created for UserId test case');
	ELSE
		PRINT ('Pass: Timeout was created for UserId test case');

	PRINT('Running InsertTimeout UnitTest - COMPLETED');
END;
GO

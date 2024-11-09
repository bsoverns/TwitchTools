/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertWarning stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN		
	PRINT('Running InsertWarning UnitTest - STARTED');

	DECLARE 
		@WarningId INT = NULL,
		@TestUserId INT = 1,
		@TestWarnedBy VARCHAR(50) = 'bsoverns',
		@TestWarningReason VARCHAR(500) = 'This is a test warning for UserId',
		@TestWarningTimestampUtc DATETIME = GETUTCDATE();

	-- Execute InsertWarning procedure
	EXEC [dbo].[InsertWarning] 
		@UserId = @TestUserId, 
		@WarnedBy = @TestWarnedBy, 
		@WarningReason = @TestWarningReason, 
		@WarningTimestampUtc = @TestWarningTimestampUtc;

	-- Retrieve the WarningId for verification
	SELECT TOP 1 @WarningId = WarningId 
	FROM [dbo].[Warnings]
	WHERE UserId = @TestUserId
	ORDER BY WarningTimestampUtc DESC;

	-- Check if WarningId is retrieved
	IF (@WarningId IS NULL)
		PRINT ('Fail: Warning was not created for UserId test case');
	ELSE
		PRINT ('Pass: Warning was created for UserId test case');

	PRINT('Running InsertWarning UnitTest - COMPLETED');
END;
GO

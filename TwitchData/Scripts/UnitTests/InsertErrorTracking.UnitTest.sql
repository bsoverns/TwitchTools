/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertErrorTrackInfo stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertErrorTrackInfo UnitTest - STARTED');

	DECLARE 
		@ErrorTrackInfoId INT = NULL,
		@TestProcessName VARCHAR(50) = 'UnitTest',
		@TestErrorDescription VARCHAR(500) = 'This is a unit test for the error tracking.';

	EXEC [dbo].[InsertErrorTrackInfo] 
		@ProcessName = @TestProcessName, 
		@ErrorDescription = @TestErrorDescription;

	SELECT TOP 1 @ErrorTrackInfoId = ErrorTrackInfoId 
	FROM [dbo].[ErrorTrackInfo]
	WHERE ProcessName = @TestProcessName AND ErrorDescription = @TestErrorDescription
	ORDER BY ErrorDateTimeUtc DESC;

	IF (@ErrorTrackInfoId IS NULL)
		PRINT ('Fail: Error was not created for test case');
	ELSE
		PRINT ('Pass: Error was created for test case');

	PRINT('Running InsertErrorTrackInfo UnitTest - COMPLETED');
END;
GO

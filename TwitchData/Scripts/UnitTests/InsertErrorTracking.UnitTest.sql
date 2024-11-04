/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertErrorTrakcing stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	

	DECLARE @ErrorTrackInfoId INT,
		@TestProcessName VARCHAR(50) = 'UnitTest',
		@TestErrorDescription VARCHAR(500) = 'This is a unit test for the error tracking.';
	DECLARE @Result TABLE (ErrorTrackInfoId INT);

	INSERT INTO @Result	
	EXEC [dbo].[InsertErrorTrackInfo] @ProcessName = @TestProcessName, @ErrorDescription = @TestErrorDescription;

	SELECT @ErrorTrackInfoId = ErrorTrackInfoId FROM @Result;
	
	IF (@ErrorTrackInfoId IS NULL)
		PRINT ('Fail: Error was not created for test case');

	ELSE
		PRINT ('Pass: Error was created for test case');
END;
GO
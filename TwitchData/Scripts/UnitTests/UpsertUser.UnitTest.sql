/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the UpsertUser stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running UpsertUser UnitTest - STARTED');
	
	DECLARE 
		@UserId INT = NULL,
		@TestTwitchUserId NVARCHAR(255) = '1234567890',
		@TestUserName NVARCHAR(255) = 'TestUser',
		@TestTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[UpsertUser] 
		@TwitchUserId = @TestTwitchUserId, 
		@UserName = @TestUserName, 
		@InteractionDateUtc = @TestTimestampUtc, 
		@UserId = @UserId OUTPUT;

	IF (@UserId IS NULL)
		PRINT ('Fail: User was not created or retrieved.');

	ELSE
	BEGIN
		PRINT ('Pass: User was created or retrieved successfully.');
		
		IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId AND UserName = @TestUserName AND TwitchUserId = @TestTwitchUserId)
			PRINT ('Pass: User data is correct in the Users table.');
		ELSE
			PRINT ('Fail: User data is incorrect in the Users table.');
	END

	PRINT('Running UpsertUser UnitTest - COMPLETE');
END;
GO
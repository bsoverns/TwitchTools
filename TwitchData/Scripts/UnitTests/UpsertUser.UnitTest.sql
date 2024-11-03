/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertUser stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running UpsertUser UnitTest - STARTED');
	DECLARE @UserId INT,
		@TestTwitchUserId NVARCHAR(255) = '1234567890',
		@TestUserName NVARCHAR(255) = 'TestUser',
		@TestTimestampUtc DATETIME = GETUTCDATE();

	EXEC [dbo].[UpsertUser] @TwitchUserId = @TestTwitchUserId, @UserName = @TestUserName, @InteractionDateUtc = @TestTimestampUtc, @UserId = @UserId OUTPUT;

	IF (@UserId IS NULL)
		PRINT ('Fail: User was not created');

	ELSE
		PRINT ('Pass: User was created');

	PRINT('Running UpsertUser UnitTest - COMPLETE');
END;
GO
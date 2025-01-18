/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertChat and InsertTextToSpeechQueue stored procedures.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/
IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertChatAndTtsUserName UnitTest - STARTED');

	DECLARE 
		@ChatId1 INT = NULL,
		@TestUserId1 INT = NULL,
		@TestTwitchUserId1 NVARCHAR(255) = NULL,
		@TestUserName1 NVARCHAR(255) = 'TestUserChat',
		@TestChatMessage1 VARCHAR(500) = 'This is a test message for the UserName without TTS test case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestIsCommand1 BIT = 0,
		@TestInteractionDateUtc1 DATETIME = GETUTCDATE(),
		@IsTextToSpeech1 BIT = 0;

	EXEC [dbo].[InsertChat]
		@UserId = @TestUserId1,
		@TwitchUserId = @TestTwitchUserId1,
		@UserName = @TestUserName1,
		@ChatMessage = @TestChatMessage1,
		@IsCommand = @TestIsCommand1,
		@InteractionDateUtc = @TestInteractionDateUtc1,
		@IsTextToSpeech = @IsTextToSpeech1;

	SELECT TOP 1 @ChatId1 = ChatId 
	FROM [dbo].[Chats] 
	WHERE ChatMessage = @TestChatMessage1 
	AND IsTextToSpeech = 0
	ORDER BY TimeStampUtc DESC;

	IF (@ChatId1 IS NULL)
		PRINT ('Fail: Chat was not created for UserName test case');
	ELSE
		PRINT ('Pass: Chat was created for UserName test case');

	-- Test Case 2: Insert a chat TTS message for the created ChatId
	DECLARE 
		@ChatId2 INT = NULL,
		@TestUserId2 INT = NULL,
		@TestTwitchUserId2 NVARCHAR(255) = NULL,
		@TestUserName2 NVARCHAR(255) = 'TestUserChat',
		@TestChatMessage2 VARCHAR(500) = 'This is a test message for the UserName with TTS test case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestIsCommand2 BIT = 0,
		@TestInteractionDateUtc2 DATETIME = GETUTCDATE(),
		@IsTextToSpeech2 BIT = 1;

	EXEC [dbo].[InsertChat]
		@UserId = @TestUserId2,
		@TwitchUserId = @TestTwitchUserId2,
		@UserName = @TestUserName2,
		@ChatMessage = @TestChatMessage2,
		@IsCommand = @TestIsCommand2,
		@InteractionDateUtc = @TestInteractionDateUtc2,
		@IsTextToSpeech = @IsTextToSpeech2;

	SELECT TOP 1 @ChatId2 = ChatId 
	FROM [dbo].[Chats] 
	WHERE ChatMessage = @TestChatMessage1 
	AND IsTextToSpeech = 1
	ORDER BY TimeStampUtc DESC;

	IF (@ChatId2 IS NULL)
		PRINT ('Fail: Chat TTS was not created for UserName test case');
	ELSE
		PRINT ('Pass: Chat TTS was created for UserName test case');


	PRINT('Running InsertChatAndTtsUserName UnitTest - COMPLETED');
END;
GO

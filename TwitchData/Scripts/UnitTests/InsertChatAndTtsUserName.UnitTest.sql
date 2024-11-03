/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertChat and InsertTextToSpeechQueue stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/
IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertChatAndTtsUserName UnitTest - STARTED');

	--Test Case 1: Insert a chat message for UserName
	DECLARE @ChatId INT,
		@TtsId INT,
		@TestUserId INT = NULL,
		@TestTwitchUserId NVARCHAR(255) = '1234567891',
		@TestUserName NVARCHAR(255) = 'TestUserChat',
		@TestChatMessage VARCHAR(500) = 'This is a test message for the UserName test case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestIsCommand BIT = 0,
		@TestInteractionDateUtc DATETIME = GETUTCDATE()

	EXEC [dbo].[InsertChat] @TwitchUserId = @TestTwitchUserId, @UserName = @TestUserName, @ChatMessage = @TestChatMessage, @IsCommand = @TestIsCommand, @InteractionDateUtc = @TestInteractionDateUtc, @ChatId = @ChatId OUTPUT;	

	IF (@ChatId IS NULL)
		PRINT ('Fail: Chat was not created for UserName test case');

	ELSE
		PRINT ('Pass: Chat was created for UserName test case');

	--Test Case 2: Insert a chat Tts message for UserName
	IF (@ChatId IS NOT NULL)
		EXEC [dbo].[InsertTextToSpeechQueue] @ChatId, @TtsId = @TtsId;

	IF (@TtsId IS NULL)
		PRINT ('Fail: Chat Tts was not created for UserName test case');

	ELSE
		PRINT ('Pass: Chat Tts was created for UserName test case');

	PRINT('Running InsertChatAndTtsUserName UnitTest - COMPLETED');
END;
GO
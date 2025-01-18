/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertChat and InsertTextToSpeechQueue stored procedures.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/
IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertChatAndTtsUserId UnitTest - STARTED');

	-- Test Case 1: Insert a chat message for a given UserId
	BEGIN
		DECLARE 
			@ChatId1 INT = NULL,
			@TtsId1 INT = NULL,
			@TestUserId1 INT = 1,
			@TestChatMessage1 VARCHAR(500) = 'This is a test message for the UserId test without TTS case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
			@TestIsCommand1 BIT = 0,
			@TestInteractionDateUtc1 DATETIME = GETUTCDATE(),
			@TestIsTextToSpeech1 BIT = 0;

		EXEC [dbo].[InsertChat] 
			@UserId = @TestUserId1, 
			@ChatMessage = @TestChatMessage1, 
			@IsCommand = @TestIsCommand1, 
			@InteractionDateUtc = @TestInteractionDateUtc1,
			@IsTextToSpeech = @TestIsTextToSpeech1;

		SELECT TOP 1 @ChatId1 = ChatId 
		FROM [dbo].[Chats]
		WHERE UserId = @TestUserId1
		AND IsTextToSpeech = 0
		ORDER BY TimeStampUtc DESC;

		IF (@ChatId1 IS NULL)	
			PRINT ('Fail: Chat was not created for UserId test case');
		ELSE
			PRINT ('Pass: Chat was created for UserId test case');
	END

	-- Test Case 2: Insert a chat TTS message for the created ChatId
	BEGIN
		DECLARE 
			@ChatId2 INT = NULL,
			@TestUserId2 INT = 1,
			@TestChatMessage2 VARCHAR(500) = 'This is a test message for the UserId test with TTS case on ' + FORMAT(GETUTCDATE(), 'yyyy-MM-dd HH:mm:ss'),
			@TestIsCommand2 BIT = 0,
			@TestInteractionDateUtc2 DATETIME = GETUTCDATE(),
			@TestIsTextToSpeech2 BIT = 0;

		EXEC [dbo].[InsertChat] 
			@UserId = @TestUserId2, 
			@ChatMessage = @TestChatMessage2, 
			@IsCommand = @TestIsCommand2, 
			@InteractionDateUtc = @TestInteractionDateUtc2,
			@IsTextToSpeech = @TestIsTextToSpeech2;

		SELECT TOP 1 @ChatId2 = ChatId 
		FROM [dbo].[Chats]
		WHERE UserId = @TestUserId2
		AND IsTextToSpeech = 1
		ORDER BY TimeStampUtc DESC;

		IF (@ChatId2 IS NULL)
			PRINT ('Fail: Chat TTS was not created for UserId test case');
		ELSE
			PRINT ('Pass: Chat TTS was created for UserId test case');
	END

	PRINT('Running InsertChatAndTtsUserId UnitTest - COMPLETE');
END;
GO

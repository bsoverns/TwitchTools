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
			@ChatId INT = NULL,
			@TtsId INT = NULL,
			@TestUserId INT = 1,
			@TestChatMessage VARCHAR(500) = 'This is a test message for the UserId test case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
			@TestIsCommand BIT = 0,
			@TestInteractionDateUtc DATETIME = GETUTCDATE();

		EXEC [dbo].[InsertChat] 
			@UserId = @TestUserId, 
			@ChatMessage = @TestChatMessage, 
			@IsCommand = @TestIsCommand, 
			@InteractionDateUtc = @TestInteractionDateUtc;

		SELECT TOP 1 @ChatId = ChatId 
		FROM [dbo].[Chats]
		WHERE UserId = @TestUserId
		ORDER BY TimeStampUtc DESC;

		IF (@ChatId IS NULL)	
			PRINT ('Fail: Chat was not created for UserId test case');
		ELSE
			PRINT ('Pass: Chat was created for UserId test case');
	END

	-- Test Case 2: Insert a chat TTS message for the created ChatId
	IF (@ChatId IS NOT NULL)
	BEGIN
		EXEC [dbo].[InsertTextToSpeechQueue] @ChatId;

		SELECT TOP 1 @TtsId = TtsId 
		FROM [dbo].[TextToSpeechQueue]
		WHERE ChatId = @ChatId
		ORDER BY TtsCreatedTimestampUtc DESC;

		IF (@TtsId IS NULL)
			PRINT ('Fail: Chat TTS was not created for UserId test case');
		ELSE
			PRINT ('Pass: Chat TTS was created for UserId test case');
	END
	ELSE
	BEGIN
		PRINT ('Skip: TTS creation test was skipped because Chat was not created.');
	END

	PRINT('Running InsertChatAndTtsUserId UnitTest - COMPLETE');
END;
GO

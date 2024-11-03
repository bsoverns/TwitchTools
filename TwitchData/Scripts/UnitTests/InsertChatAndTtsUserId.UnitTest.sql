/****************************************************************************************
*  Created by: BS
*  Purpose: This script is used to test the InsertChat and InsertTextToSpeechQueue stored procedure.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/
IF (DB_NAME() = 'TestTwitchData')
BEGIN	
	PRINT('Running InsertChatAndTtsUserId UnitTest - STARTED');

	--Test Case 1: Insert a chat message for default UserId
	BEGIN
	DECLARE @ChatId INT,
		@TtsId INT,
		@TestUserId INT = 1,
		@TestChatMessage VARCHAR(500) = 'This is a test message for the UserId test case on ' + FORMAT(GETUTCDATE(),'yyyy-MM-dd HH:mm:ss'),
		@TestIsCommand BIT = 0,
		@TestInteractionDateUtc DATETIME = GETUTCDATE()

	EXEC [dbo].[InsertChat] @UserId = @TestUserId, @ChatMessage = @TestChatMessage, @IsCommand = @TestIsCommand, @InteractionDateUtc = @TestInteractionDateUtc, @ChatId = @ChatId OUTPUT;
	PRINT @ChatId;

	IF (@ChatId IS NULL)	
		PRINT ('Fail: Chat was not created for UserId test case');

	ELSE
		PRINT ('Pass: Chat was created for UserId test case');
	END

	--Test Case 2: Insert a chat Tts message for default UserId
	IF (@ChatId IS NOT NULL)
		EXEC [dbo].[InsertTextToSpeechQueue] @ChatId, @TtsId = @TtsId OUTPUT;

	IF (@TtsId IS NULL)
		PRINT ('Fail: Chat Tts was not created for UserId test case');

	ELSE
		PRINT ('Pass: Chat Tts was created for UserId test case');

	PRINT('Running InsertChatAndTtsUserId UnitTest - COMPLETE');
END;
GO
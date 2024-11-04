/****************************************************************************************
*  Created by: BS
*  Purpose: This script deletes all records from tables in reverse order, 
*           ensuring UserId 1 in the Users table is not deleted.
*  Created on: 2024-11-02
*  Last Modified on: 2024-11-02
*
****************************************************************************************/

IF (DB_NAME() = 'TestTwitchData')
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

		PRINT ('Deleting records from Bans...');
        DELETE FROM Bans;

        PRINT ('Deleting records from Timeouts...');
        DELETE FROM Timeouts;

		PRINT ('Deleting records from TextToSpeechQueue...');
        DELETE FROM TextToSpeechQueue;

        PRINT ('Deleting records from Chats...');
        DELETE FROM Chats;

        PRINT ('Deleting records from Warnings...');
        DELETE FROM Warnings;

        PRINT ('Deleting records from ErrorTrackInfo...');
        DELETE FROM ErrorTrackInfo;

        PRINT ('Deleting records from Users, except UserId 1...');
        DELETE FROM Users 
        WHERE UserId <> 1;

        COMMIT TRANSACTION
        PRINT ('Records successfully deleted in reverse order.');
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        PRINT ('Error occurred while deleting records: ' + @ErrorMessage);
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

/*
SELECT * FROM Users
SELECT * FROM Chats
SELECT * FROM TextToSpeechQueue
SELECT * FROM Warnings
SELECT * FROM Timeouts
SELECT * FROM Bans
SELECT * FROM ErrorTrackInfo
*/

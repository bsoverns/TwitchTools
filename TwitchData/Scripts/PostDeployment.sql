/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Unit tests for stored procedures
:r .\UnitTests\UpsertUser.UnitTest.sql
:r .\UnitTests\InsertChatAndTtsUserId.UnitTest.sql
:r .\UnitTests\InsertChatAndTtsUserName.UnitTest.sql
:r .\UnitTests\InsertWarningUserId.UnitTest.sql
:r .\UnitTests\InsertWarningUserName.UnitTest.sql
:r .\UnitTests\InsertTimeoutUserId.UnitTest.sql
:r .\UnitTests\InsertTimeoutUserName.UnitTest.sql
:r .\UnitTests\InsertBanUserId.UnitTest.sql
:r .\UnitTests\InsertBanUserName.UnitTest.sql
:r .\UnitTests\InsertErrorTracking.UnitTest.sql

-- Unit test cleanup except UserId = 1
--:r .\CleanUp\CleanUpTestData.Cleanup.sql
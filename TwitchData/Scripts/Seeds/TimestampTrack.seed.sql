
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TimestampTrack')
	AND NOT EXISTS(SELECT 1 FROM dbo.TimeStampTrack WHERE TimestampName = 'LastBotConnectionTimestamp')
BEGIN
	PRINT 'Seeding LastBotConnectionTimestamp into "dbo.TimestampTrack" STARTED';

	DECLARE @DateTimeUtc DATETIME2 = GETUTCDATE();

	EXEC [dbo].[UpsertTimestampTrack] @TimestampName = 'LastBotConnectionTimestamp', @TimestampValue = @DateTimeUtc;

	PRINT 'Seeding LastBotConnectionTimestamp into "dbo.TimestampTrack" COMPLETED';
END;	
GO
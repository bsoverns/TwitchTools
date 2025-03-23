CREATE TABLE [dbo].[TimeStampTrack]
(
	[TimeStampTrackId] INT IDENTITY(1,1) NOT NULL,
	[TimestampName] VARCHAR(50) NOT NULL,
	[TimestampValue] DATETIME2 NOT NULL,
	CONSTRAINT [PK_TimeStampTrack] PRIMARY KEY CLUSTERED ([TimeStampTrackId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_TimeStampTrack_TimestampName]
ON [dbo].[TimeStampTrack] ([TimestampName] ASC)
INCLUDE ([TimestampValue]);
GO
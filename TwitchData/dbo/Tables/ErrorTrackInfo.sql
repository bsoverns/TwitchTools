CREATE TABLE [dbo].[ErrorTrackInfo]
(
	[ErrorTrackInfoId] INT IDENTITY(1, 1) NOT NULL,
	[ProcessName] VARCHAR(50) NOT NULL,
	[ErrorDescription] VARCHAR(500) NOT NULL,
	[ErrorDateTimeUtc] DATETIME NOT NULL CONSTRAINT [DF_ErrorTrackInfo_ErrorDateTimeUtc] DEFAULT GETUTCDATE(),
	[ResolvedTimeUtc] DATETIME NULL,
	[IsResolved] BIT NOT NULL CONSTRAINT [DF_ErrorTrackInfo_IsResolved] DEFAULT 0,
	CONSTRAINT [PK_ErrorTrackInfo_ErrorTrackInfoId] PRIMARY KEY CLUSTERED ([ErrorTrackInfoId] ASC)
);

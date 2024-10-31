CREATE TABLE [dbo].[Users]
(
  [UserId] INT IDENTITY(1, 1) NOT NULL,
  [UserName] VARCHAR(50) NOT NULL,
  [FirstInteractionDateTimeUtc] DATETIME NOT NULL CONSTRAINT [DF_Users_FirstInteractionDateTimeUtc] DEFAULT GETUTCDATE(),
  [LastInteractionDateTimeUtc] DATETIME,
  CONSTRAINT [PK_Users_UserId] PRIMARY KEY CLUSTERED ([UserId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Users_UserName] 
ON [dbo].[Users] ([UserName] ASC)
WITH (ONLINE = ON);
GO
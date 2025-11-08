CREATE VIEW [dbo].[vGetModerationActions]
AS
SELECT 'Warning' AS [Type], UserId, WarningReason AS [Reason] FROM dbo.Warnings WHERE IsComplete = 0
UNION ALL
SELECT 'Timeout' AS [Type], UserId, TimeoutReason AS [Reason] FROM dbo.Timeouts WHERE IsComplete = 0
UNION ALL
SELECT 'Ban' AS [Type], UserId, BannedReason AS [Reason] FROM dbo.Bans WHERE IsComplete = 0
GO
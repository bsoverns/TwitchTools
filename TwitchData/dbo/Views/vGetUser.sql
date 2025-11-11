CREATE VIEW [dbo].[vGetUser]
AS
SELECT UserId, UserName
FROM dbo.Users WITH(NOLOCK)
GO
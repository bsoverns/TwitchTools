﻿CREATE VIEW [dbo].[vGetUser]
WITH SCHEMABINDING
AS
SELECT UserId, UserName
FROM dbo.Users
GO
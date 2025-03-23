CREATE PROCEDURE [dbo].[UpsertTimestampTrack]
(
    @TimestampName VARCHAR(50),
    @TimestampValue DATETIME2 = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@TimestampValue IS NULL)
        SET @TimestampValue = GETUTCDATE();

    MERGE INTO dbo.TimestampTrack AS target
    USING 
    (
        SELECT 
            @TimestampName AS TimestampName
            ,@TimestampValue AS TimestampValue
    ) AS source
    ON target.TimestampName = source.TimestampName

    WHEN MATCHED AND target.TimestampValue != source.TimestampValue THEN
        UPDATE SET target.TimestampValue = source.TimestampValue

    WHEN NOT MATCHED THEN
        INSERT (TimestampName, TimestampValue)
        VALUES (source.TimestampName, source.TimestampValue);
END;
GO
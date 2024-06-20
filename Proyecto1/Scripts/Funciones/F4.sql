USE BD2;

GO
-- Func_logger
CREATE FUNCTION proyecto1.F4 ()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM proyecto1.HistoryLog
);
GO

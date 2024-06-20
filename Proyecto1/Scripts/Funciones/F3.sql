USE BD2;

GO
-- Func_notification_usuarios
CREATE FUNCTION proyecto1.F3 (@UserId uniqueidentifier)  -- Id de Usuarios
RETURNS TABLE
AS
RETURN
(
    SELECT n.Id, n.Message, n.Date
    FROM proyecto1.Notification n
    WHERE n.UserID = @UserId
);
GO

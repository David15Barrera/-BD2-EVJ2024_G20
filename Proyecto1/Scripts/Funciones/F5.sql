USE BD2;

GO
-- Func_usuarios
CREATE FUNCTION proyecto1.F5 (@Id uniqueidentifier) --id usuario
RETURNS TABLE
AS
RETURN (
    SELECT 
        u.Firstname,
        u.Lastname,
        u.Email,
        u.DateOfBirth,
        ps.Credits,
        r.RoleName
    FROM proyecto1.Usuarios u
    INNER JOIN proyecto1.ProfileStudent ps ON u.Id = ps.UserId
    INNER JOIN proyecto1.UsuarioRole ur ON u.Id = ur.UserId
    INNER JOIN proyecto1.Roles r ON ur.RoleId = r.Id
    WHERE u.Id = @Id
);
GO

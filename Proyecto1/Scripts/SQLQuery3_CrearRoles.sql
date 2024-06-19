use BD2;

go

CREATE PROCEDURE proyecto1.PR4
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DescripcionLog NVARCHAR(100);
    DECLARE @RoleId uniqueidentifier = NEWID(); -- Generar nuevo Id único

    -- Verificar si el rol ya existe en la tabla Roles
    IF NOT EXISTS (SELECT * FROM proyecto1.Roles WHERE RoleName = @RoleName)
    BEGIN
        -- Insertar el nuevo rol en la tabla Roles con el nuevo Id generado
        INSERT INTO proyecto1.Roles (Id, RoleName)
        VALUES (@RoleId, @RoleName);

        -- Registro en HistoryLog
        SET @DescripcionLog = 'Creación de rol ' + @RoleName + ' exitosa';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @DescripcionLog);
    END
    ELSE
    BEGIN
        -- Registro en HistoryLog si el rol ya existe
        SET @DescripcionLog = 'El rol ' + @RoleName + ' ya existe en la tabla Roles';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @DescripcionLog);
    END
END;
GO

-- Para hacer pruebas;
-- Creamos un nuevo rol
EXEC proyecto1.PR4 @RoleName = 'NuevoRol';

--verificamos si existe
SELECT * FROM proyecto1.Roles;

--Verificamos si ya se ingreso en el historia

SELECT * FROM proyecto1.HistoryLog;
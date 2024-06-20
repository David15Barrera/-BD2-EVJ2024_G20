USE BD2;

CREATE PROCEDURE proyecto1.PR1
    @Firstname VARCHAR(max),
    @Lastname VARCHAR(max), 
    @Email VARCHAR(max), 
    @DateOfBirth datetime2(7), 
    @Password VARCHAR(max), 
    @Credits INT
AS
BEGIN
    DECLARE @UserId uniqueidentifier;
    DECLARE @RolId uniqueidentifier;
    DECLARE @ErrorMessage NVARCHAR(250);
    DECLARE @ErrorSeverity INT;
    DECLARE @Validation INT; 

    BEGIN TRY
        -- Validaciones de cada campo

        SET @Validation = 1; -- todo esta valido

        -- validacion del Firtsname, no deve ser null ni vacio 
        IF (@Firstname IS NULL OR @Firstname = '')
        BEGIN 
            SET @Validation = 0;      --cambiar el valor para reportar error de validez
            SET @ErrorMessage = 'El campo < Firstname > no puede ir vacio ni null';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- Validacion del apellido vacio ni null
        IF (@Lastname IS NULL OR @Lastname = '')
        BEGIN 
            SET @Validation = 0;
            SET @ErrorMessage = 'El campo < Lastname > no puede ir vacio ni null';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- correo vacio
        IF (@Email IS NULL OR @Email = '')
        BEGIN 
            SET @Validation = 0;
            SET @ErrorMessage = 'El campo < Email > no puede ir vacio ni null';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- fecha vacia 
        IF (@DateOfBirth IS NULL)
        BEGIN
            SET @Validation = 0;
            SET @ErrorMessage = 'El campo < DateOfBirth > no puede ir vacio ni null';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- contase�a vacia 
        IF (@Password IS NULL OR @Password = '')
        BEGIN
            SET @Validation = 0;
            SET @ErrorMessage = 'El < Password > no puede estar vacio ni null';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- creditos con valor negativo 
        IF (@Credits < 0)
        BEGIN
            SET @Validation = 0;
            SET @ErrorMessage = 'El campo < Credits > no puede admite una cantidad de creditos negativa';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END --finalizacion del area de validaciones

    	-- Inicio de transacci�n
        BEGIN TRANSACTION;
       
    	-- Validaci�n de datos utilizando el procedimiento PR6
        DECLARE @IsValid BIT;
        EXEC proyecto1.PR6 'Usuarios', @Firstname, @Lastname, NULL, NULL, @IsValid OUTPUT;
        IF(@IsValid = 0)
        BEGIN
            SET @ErrorMessage = 'Los campos < @Firstname, @Lastname > solo deben contener letras';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage,@ErrorSeverity,1);
            RETURN;
        END     

        -- Validar si el que el email no est� asociado con ninguna otra cuenta dentro del sistema
        IF EXISTS (SELECT * FROM proyecto1.Usuarios WHERE Email = @Email)
        BEGIN
            SET @ErrorMessage = 'El campo < Email > ya tiene un usuario asociado';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END

        -- Creaci�n de rol estudiante
        SET @RolId = (SELECT Id FROM proyecto1.Roles WHERE RoleName = 'Student');
        IF @RolId IS NULL
        BEGIN
            SET @ErrorMessage = 'Se intento asociar un rol <Student> al usuario, valor no encontrado en la tabla <Roles>';
            SET @ErrorSeverity = 16;
            RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
            RETURN;
        END
        
        -- Insert tabla Usuarios
        SET @UserId = NEWID();
        INSERT INTO proyecto1.Usuarios(Id, Firstname, Lastname, Email, DateOfBirth, Password, LastChanges, EmailConfirmed)
        VALUES (@UserId, @Firstname, @Lastname, @Email, @DateOfBirth, @Password, GETDATE(), 1);

        -- Insert tabla UsuarioRole
        INSERT INTO proyecto1.UsuarioRole (RoleId, UserId, IsLatestVersion)
        VALUES (@RolId, @UserId, 1);

        -- Insert tabla ProfileStudent
        INSERT INTO proyecto1.ProfileStudent (UserId, Credits)
        VALUES (@UserId, @Credits);

        -- Insert tabla TFA
        INSERT INTO proyecto1.TFA (UserId, Status, LastUpdate)
        VALUES (@UserId, 1, GETDATE());

        -- Insert tabla Notification
        INSERT INTO proyecto1.Notification (UserId, Message, Date)
        VALUES (@UserId,'Su registro con los datos: ' + @Firstname + ' ' + @Lastname + ' con email: ' + @Email +' Se ha registrado satisfactoriamente', GETDATE());
		PRINT 'El estudiante ha sido registrado satisfactoriamente';
       
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
          -- Error - cancelar transacci�n 
        IF(@Validation = 1)
        BEGIN
            ROLLBACK;
        END
        SELECT @ErrorMessage = ERROR_MESSAGE();
		-- Registro del error en la tabla HistoryLog
        INSERT INTO proyecto1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error en el procedimiento PR1: < Regristro de Usuarios >  Motivo: ' + @ErrorMessage);
       	PRINT 'Registro instatisfactorio, se ha reportado un error en el historial'
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
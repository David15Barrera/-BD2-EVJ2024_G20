USE BD2;

CREATE PROCEDURE proyecto1.PR2
    @Email VARCHAR(max),
    @CodCourse INT
AS 
BEGIN
    DECLARE @UserId uniqueidentifier;
    DECLARE @RolId uniqueidentifier;
    DECLARE @ErrorMessage NVARCHAR(250);
    DECLARE @ErrorSeverity INT;
    DECLARE @Validation INT; 


    BEGIN TRY
        -- seccion para todas la validaciones de los campos recibidos
        SET @Validation = 1;      

        -- validacion de correo vacio
        IF (@Email IS NULL OR @Email = '')
            BEGIN 
                SET @Validation = 0;
                SET @ErrorMessage = 'El campo < Email > no puede ir vacio ni null';
                SET @ErrorSeverity = 16;
                RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                RETURN;
            END
        
        -- creditos con valor negativo 
        IF (@CodCourse < 0)
            BEGIN
                SET @Validation = 0;
                SET @ErrorMessage = 'El campo < CodCourse > no puede admite una cantidad negativa';
                SET @ErrorSeverity = 16;
                RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                RETURN;
            END

        BEGIN TRANSACTION;
            --obtenr el UserId
            SET @UserId = (SELECT Id FROM proyecto1.Usuarios WHERE Email = @Email);
            IF @UserId IS NULL
                BEGIN
                    SET @ErrorMessage = 'El campo < Email > no esta asociado a ningun usuario';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END

            --obtener y validar que el cruso exista
             IF NOT EXISTS (SELECT * FROM proyecto1.Course WHERE CodCourse = @CodCourse)
                BEGIN
                    SET @ErrorMessage = 'El campo < CodCourse > no esta asociado a ningun curso';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END

            --validar que en email y codigo de curso no se repitan
             IF EXISTS (SELECT * FROM proyecto1.CourseTutor WHERE CourseCodCourse = @CodCourse AND TutorId = @UserId)
                BEGIN
                    SET @ErrorMessage = 'El usuario ya esta asociado como tutor al curso';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END

            --validar el usuario tenga cuenta activa, EmailConfirmed == 1
            DECLARE @EmailIsActive BIT;
            SET @EmailIsActive = (SELECT EmailConfirmed FROM proyecto1.Usuarios WHERE Email = @Email );
            IF @EmailIsActive IS NULL
                BEGIN
                    SET @ErrorMessage = 'El campo < Email > no esta asociado a ningun usuario';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END
            ELSE
                IF (@EmailIsActive = 0)
                    BEGIN
                        SET @ErrorMessage = 'El usuario no tiene la cuenta activa';
                        SET @ErrorSeverity = 16;
                        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                        RETURN;
                    END

            --obtener rol de tutor 
            SET @RolId = (SELECT Id FROM proyecto1.Roles WHERE RoleName = 'Tutor');
            IF @RolId IS NULL
                BEGIN
                    SET @ErrorMessage = 'Se intento asociar un rol <Tutor> al usuario, valor no encontrado en la tabla <Roles>';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END

            DECLARE @RolIstutor BIT;
            SET @RolIstutor = (SELECT IsLatestVersion FROM proyecto1.UsuarioRole WHERE RoleId = @RolId AND UserId = @UserId);
            IF @RolIstutor IS NULL
                BEGIN
                    -- actulizar el campo IsLatestVersion = 0  
                    UPDATE proyecto1.UsuarioRole SET IsLatestVersion = 0 WHERE UserId = @UserId;

                    -- Insert tabla UsuarioRole 
                    INSERT INTO proyecto1.UsuarioRole (RoleId, UserId, IsLatestVersion) VALUES (@RolId, @UserId, 1);
                END
            
            --en TutorProfile en campo tutor code comvinacion de aux+ para su codigo
            DECLARE @codeT NVARCHAR(250);
            IF NOT EXISTS (SELECT * FROM proyecto1.TutorProfile WHERE UserId = @UserId)
                BEGIN
                    SET @codeT = LEFT(NEWID(), 8);
                    INSERT INTO proyecto1.TutorProfile (UserId, TutorCode) VALUES (@UserId, @codeT);
                END

            --insert del curso tutor
            INSERT INTO proyecto1.CourseTutor (TutorId, CourseCodCourse) VALUES (@UserId, @CodCourse);

            -- Insert tabla Notification
            SET @codeT = (SELECT TutorCode FROM proyecto1.TutorProfile WHERE UserId = @UserId);
            INSERT INTO proyecto1.Notification (UserId, Message, Date)
            VALUES (@UserId,'Su cambio de Rol a tutor ha sido realizado satisfactoriamente, codigo de curso donde sera tutor: ' + CONVERT(VARCHAR(10), @CodCourse) + ' su codigo de tutor es: '+ @codeT, GETDATE());
            PRINT 'Cambio de rol Realizado satisfactoriamente';
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
        VALUES (GETDATE(), 'Error en el procedimiento PR2: < Cambio de Rol >  Motivo: ' + @ErrorMessage);
       	PRINT 'Cambio de rol instatisfactorio, se ha reportado un error en el historial'
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
USE BD2;

CREATE PROCEDURE proyecto1.PR3
    @Email VARCHAR(max),
    @CodCourse INT
AS 
BEGIN
    DECLARE @UserId uniqueidentifier;
    DECLARE @ErrorMessage NVARCHAR(250);
    DECLARE @ErrorSeverity INT;
    DECLARE @Validation INT; 
    DECLARE @Credits INT;
    DECLARE @CreditsRequired INT;

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
             SET @CreditsRequired = (SELECT CreditsRequired FROM proyecto1.Course WHERE CodCourse = @CodCourse)
             IF @CreditsRequired IS NULL
                BEGIN
                    SET @ErrorMessage = 'El campo < CodCourse > no esta asociado a ningun curso';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END

            --verificar si sus crditos cumplen con el minimo
            SET @Credits = (SELECT Credits FROM proyecto1.ProfileStudent WHERE UserId = @UserId )
            IF @Credits IS NULL
                BEGIN
                    SET @ErrorMessage = 'El usuario no cuenta con un perfil de Student (estudiante)';
                    SET @ErrorSeverity = 16;
                    RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                    RETURN;
                END
            ELSE
                IF (@Credits < @CreditsRequired)
                    BEGIN
                        SET @ErrorMessage = 'El usuario no cuenta con los creditos requeridos para realizar la asignacion';
                        SET @ErrorSeverity = 16;
                        RAISERROR(@ErrorMessage, @ErrorSeverity, 1);
                        RETURN;
                    END

            
            --validar que el codigo de curso y usuario no se repitan en la tabla courseAssignmen
            IF EXISTS (SELECT * FROM proyecto1.CourseAssignment WHERE CourseCodCourse = @CodCourse AND StudentId = @UserId)
                BEGIN
                    SET @ErrorMessage = 'El usuario (estudiante) ya esta asignado al curso';
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
            
            --insert asignacion
            INSERT INTO proyecto1.CourseAssignment (StudentId, CourseCodCourse) VALUES (@UserId, @CodCourse);

            -- Insert tabla Notification, estudiante y tutor
            --estudiante
            INSERT INTO proyecto1.Notification (UserId, Message, Date)
            VALUES (@UserId,'Su asignacion al curso a sido exitosa, codigo de curso asignado: ' + CONVERT(VARCHAR(10), @CodCourse), GETDATE());
            
            --tutor
            DECLARE @TutorId uniqueidentifier;
            SET @TutorId = (SELECT TOP 1 TutorId FROM proyecto1.CourseTutor WHERE CourseCodCourse = @CodCourse ORDER BY TutorId DESC);
            IF @TutorId IS NOT NULL
                BEGIN
                    INSERT INTO proyecto1.Notification (UserId, Message, Date)
                    VALUES  (@TutorId, 'Se ha asignado el estudiante con email: '+ CONVERT(VARCHAR(80), @Email) + ' al curso con codigo: '+ CONVERT(VARCHAR(10), @CodCourse) +' donde usted es Tutor',GETDATE());
                END
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
        VALUES (GETDATE(), 'Error en el procedimiento PR3: < Asignacion de Curso >  Motivo: ' + @ErrorMessage);
       	PRINT 'Asigancacion a curso instatisfactorio, se ha reportado un error en el historial'
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
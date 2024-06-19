use bd2;
 go

CREATE PROCEDURE proyecto1.PR5 
    @CodCourse INT, 
    @Name NVARCHAR(MAX), 
    @CreditsRequired INT
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @Description NVARCHAR(MAX);
    DECLARE @IsValid BIT;

    -- Validar que los parámetros sean correctos
    IF @CreditsRequired < 0
    BEGIN
        SET @Description = 'Insercion de Curso Fallida: Creditos no pueden ser negativos';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @Description);
        SELECT @Description AS 'Error';
        RETURN;
    END

    IF @CodCourse < 0
    BEGIN
        SET @Description = 'Insercion de Curso Fallida: Codigo de Curso no puede ser negativo';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @Description);
        SELECT @Description AS 'Error';
        RETURN;
    END

    -- Validar el nombre y los créditos requeridos usando PR6
--    EXEC proyecto1.PR6 'Course', NULL, NULL, @Name, @CreditsRequired, @IsValid OUTPUT;

    IF @IsValid = 0
    BEGIN
        SET @Description = 'Insercion de Curso Fallida: Nombre o Creditos Incorrectos';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @Description);
        SELECT @Description AS 'Error';
        RETURN;
    END

	 -- Ver si el CodCourse ya existe
    IF EXISTS (SELECT 1 FROM proyecto1.Course WHERE CodCourse = @CodCourse)
    BEGIN
        SET @Description = 'Insercion de Curso Fallida: Primary Key duplicada';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @Description);
        SELECT @Description AS 'Error';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar el curso en la tabla Course
        INSERT INTO proyecto1.Course (CodCourse, Name, CreditsRequired) 
        VALUES (@CodCourse, @Name, @CreditsRequired);

        -- Operación exitosa
        SET @Description = 'Insercion de Curso exitosa';
        INSERT INTO proyecto1.HistoryLog ([Date], Description)
        VALUES (GETDATE(), @Description);

        SELECT @Description AS 'Mensaje';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
     -- Para manejar cualquier error
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        SET @Description = 'Insercion de Curso Fallida: ' + ERROR_MESSAGE();
        BEGIN TRY
            INSERT INTO proyecto1.HistoryLog ([Date], Description)
            VALUES (GETDATE(), @Description);
        END TRY
        BEGIN CATCH
            -- Manejar cualquier error adicional aquí en el Historial
            PRINT 'Error al insertar en HistoryLog: ' + ERROR_MESSAGE();
        END CATCH;
        
        SELECT @Description AS 'Error';
    END CATCH;
END;

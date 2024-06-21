USE BD2;
GO
-- Validación de Datos
CREATE PROCEDURE proyecto1.PR6
    @EntityName NVARCHAR(50),
    @FirstName NVARCHAR(MAX) = NULL,
    @LastName NVARCHAR(MAX) = NULL,
    @Name NVARCHAR(MAX) = NULL,
    @CreditsRequired INT = NULL,
    @IsValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones de Usuario
    IF @EntityName = 'Usuarios'
    BEGIN
        IF ISNULL(@FirstName, '') NOT LIKE '%[^a-zA-Z ]%' AND ISNULL(@LastName, '') NOT LIKE '%[^a-zA-Z ]%'
            SET @IsValid = 1;
        ELSE
            SET @IsValid = 0;
    END
    -- Validacion de Curso
    ELSE IF @EntityName = 'Course'
    BEGIN
        -- Validación del nombre del curso
        IF @Name IS NOT NULL
        BEGIN
            IF @Name LIKE '[a-zA-Z]%' AND @Name NOT LIKE '%[^a-zA-Z0-9 ]%'
                SET @IsValid = 1;
            ELSE
                SET @IsValid = 0;
        END
        ELSE
            SET @IsValid = 0;

        -- Validación de créditos requeridos
        IF @CreditsRequired IS NOT NULL AND @CreditsRequired > 0
            SET @IsValid = @IsValid & 1;
        ELSE
            SET @IsValid = 0;
    END
    ELSE
    BEGIN
        -- No valida
        SET @IsValid = 0;
    END;
END;

GO
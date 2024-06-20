USE BD2;

GO
--Func_course_usuarios
CREATE FUNCTION proyecto1.F1 (@CodCourse INT)
RETURNS TABLE
AS
RETURN
(
    SELECT u.Id, u.Firstname, u.Lastname, u.Email
    FROM proyecto1.Usuarios u
    JOIN proyecto1.CourseAssignment ca ON u.Id = ca.StudentId
    WHERE ca.CourseCodCourse = @CodCourse
);
GO

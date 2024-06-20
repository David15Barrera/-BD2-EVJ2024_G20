USE BD2;

GO
-- Func_tutor_course
CREATE FUNCTION proyecto1.F2 (@Id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.CodCourse AS CourseCodCourse, c.Name AS CourseName
    FROM proyecto1.Course c
    JOIN proyecto1.CourseTutor ct ON c.CodCourse = ct.CourseCodCourse
    JOIN proyecto1.TutorProfile tp ON ct.TutorId = tp.UserId
    WHERE tp.Id = @Id -- Filtra por el Id del TutorProfile
);
GO

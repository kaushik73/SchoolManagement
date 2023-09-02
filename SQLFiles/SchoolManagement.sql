CREATE TABLE Courses (
    CourseId VARCHAR(2) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL
);

ALTER TABLE
    Courses
ALTER COLUMN
    CourseId VARCHAR(10);

CREATE TABLE StudentDetail (
    StudentID VARCHAR(10) PRIMARY KEY,
    StudentName VARCHAR(50) NOT NULL,
    StudentEmail VARCHAR(100) NOT NULL,
    GuardianEmail VARCHAR(100) NOT NULL,
    StudentPhoneNumber VARCHAR(20) NOT NULL
);

Create TABLE TeacherDetail (
    TeacherID Varchar(10) PRIMARY KEY,
    TeacherName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL
);

Create TABLE AdminDetail (
    AdminID Varchar(10) PRIMARY KEY,
    AdminName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL
) CREATE TABLE StudentInfo (
    StudentID VARCHAR(10),
    CourseID VARCHAR(2),
    CONSTRAINT PK_StudentInfo PRIMARY KEY (StudentID, CourseID),
    CONSTRAINT FK_StudentInfo_StudentId FOREIGN KEY (StudentID) REFERENCES StudentDetail (StudentID),
    CONSTRAINT FK_StudentInfo_CourseId FOREIGN KEY (CourseID) REFERENCES Courses (CourseID)
);

CREATE TABLE TeacherInfo (
    TeacherID Varchar(10),
    CourseID VARCHAR(2),
    CONSTRAINT PK_TeacherInfo PRIMARY KEY (TeacherID, CourseID),
    CONSTRAINT FK_TeacherInfo_TeacherId FOREIGN KEY (TeacherID) REFERENCES TeacherDetail (TeacherID),
    CONSTRAINT FK_TeacherInfo_CourseId FOREIGN KEY (CourseID) REFERENCES Courses (CourseID)
);

Create procedure editUserData @userId varchar(2),
@name varchar(100),
@phoneNumber Varchar(100),
@guardianEmail Varchar(100),
@status INT = 0 OUTPUT as begin begin try DECLARE @tableName VARCHAR(100);

IF @userId LIKE 'S%'
UPDATE
    StudentDetail
SET
    StudentName = @name,
    StudentPhoneNumber = @phoneNumber,
    GuardianEmail = @guardianEmail
WHERE
    StudentId = @userId;

ELSE IF @userId LIKE 'T%'
UPDATE
    TeacherDetail
SET
    TeacherName = @name,
    PhoneNumber = @phoneNumber
WHERE
    TeacherId = @userId;

ELSE
UPDATE
    AdminDetail
SET
    AdminName = @name,
    PhoneNumber = @phoneNumber
WHERE
    AdminId = @userId;

set
    @status = 1;

end try begin catch
set
    @status = 0
end catch
end
go
    Create PROCEDURE GetStudentsDetails @searchPattern NVARCHAR(100) = NULL,
    @currentStudentId VARCHAR(10) = NULL AS BEGIN
SELECT
    SD.StudentID,
    SD.StudentName,
    STRING_AGG(C.CourseName, ', ') AS CourseNames
FROM
    StudentDetail SD
    LEFT JOIN StudentInfo SI ON SD.StudentID = SI.StudentID
    LEFT JOIN Courses C ON SI.CourseID = C.CourseId
WHERE
    (
        @searchPattern IS NULL
        OR SD.StudentName LIKE '%' + @searchPattern + '%'
    )
    AND (
        @currentStudentId IS NULL
        OR SD.StudentID <> @currentStudentId
    )
GROUP BY
    SD.StudentID,
    SD.StudentName;

END;

go
    Create PROCEDURE GetTeachersDetails @searchPattern VARCHAR(100) = NULL,
    @currentTeacherId VARCHAR(10) = NULL AS BEGIN
SELECT
    TD.TeacherID,
    TD.TeacherName,
    STRING_AGG(C.CourseName, ', ') AS CourseNames
FROM
    TeacherDetail TD
    LEFT JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
    LEFT JOIN Courses C ON TI.CourseID = C.CourseId
WHERE
    (
        @searchPattern IS NULL
        OR TD.TeacherName LIKE '%' + @searchPattern + '%'
    )
    AND (
        @currentTeacherID IS NULL
        OR TD.TeacherID <> @currentTeacherId
    )
GROUP BY
    TD.TeacherID,
    TD.TeacherName;

END;

go
    Create PROCEDURE GetCourseTeachers @courseName VARCHAR(100) AS BEGIN DECLARE @teacherList VARCHAR(MAX) = '';

SELECT
    @teacherList = STRING_AGG(TD.TeacherName, ', ')
FROM
    TeacherDetail TD
    JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
    JOIN Courses C ON TI.CourseID = C.CourseId
WHERE
    C.CourseName = @courseName;

SELECT
    COALESCE(@teacherList, '') AS TeacherList;

END;

go
    CREATE PROCEDURE GetCourseTeachersEmails @courseName NVARCHAR(100) AS BEGIN DECLARE @Emails NVARCHAR(MAX);

SELECT
    @Emails = STRING_AGG(TD.Email, ', ')
FROM
    TeacherDetail TD
    INNER JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
    INNER JOIN Courses C ON TI.CourseID = C.CourseID
WHERE
    C.CourseName = @courseName;

IF @Emails IS NULL
SET
    @Emails = '';

SELECT
    @Emails AS TeacherEmails;

END;

go
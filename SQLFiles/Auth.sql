CREATE TABLE Auth (
    UserId VARCHAR(2) PRIMARY KEY,
    Email VARCHAR(100) NOT NULL,
    Password VARCHAR(100) NOT NULL,
    RoleId varchar(2) NOT NULL,
    CONSTRAINT FK_Auth_RoleId FOREIGN KEY (RoleId) REFERENCES Role (RoleId)
);

CREATE TABLE Role (
    RoleId Varchar(2) PRIMARY KEY,
    Type VARCHAR(20) NOT NULL
);

create procedure editUserData @userId varchar(2),
@email varchar(100),
@password Varchar(100),
@status INT = 0 OUTPUT as begin begin try
UPDATE
    Auth
SET
    email = @email,
    password = @password
WHERE
    UserId = @userId;

set
    @status = 1;

end try begin catch
set
    @status = 0
end catch
end
go
    --  Mine
INSERT INTO
    Role (RoleId, Type)
VALUES
    (1, 'student'),
    (2, 'teacher'),
    (3, 'admin');

INSERT INTO
    Auth (UserId, Email, Password, RoleId)
VALUES
    ('S1', 'marrychrish@gmail.com', 's11111', 1),
    ('S2', 'kanikamishra@gmail.com', 's22222', 1),
    ('S3', 'kanikagandhi@gmail.com', 's22222', 1),
    ('S4', 'marryoberoi@gmail.com', 's33333', 1),
    ('S5', 'krishgupta@gmail.com', 's44444', 1),
    ('S6', 'chitreshmalik@gmail.com', 's55555', 1),
    ('T1', 'Ashley@gmail.com', 't11111', 2),
    ('T2', 'Abhavy@gmail.com', 't22222', 2),
    ('T3', 'dinesh@gmail.com', 't33333', 2),
    ('T4', 'rajeev@gmail.com', 't44444', 2),
    ('A2', 'manan@gmail.com', 'Manan@1', 3),
    ('A1', 'admin@gmail.com', 'a11111', 3),
    ('T5', 'tanushree@gmail.com', 't55555', 2);

go
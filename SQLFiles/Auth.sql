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
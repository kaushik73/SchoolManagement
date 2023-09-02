<!DOCTYPE html>
<html lang="en">
<head>
<link rel="stylesheet" href="../style.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
      crossorigin="anonymous">
<title>
Teacher View
</title>
</head>
<body>
<cfif thisTag.executionMode eq 'start'>
    <cfset utils = createObject('component', 'finalAssignment.components.utils')>
    <cfset currentDateAndTime = now()>
    <cfset currentDate = dateFormat(currentDateAndTime, "mm/dd/yyyy")>
    <cfset currentTime = timeFormat(currentDateAndTime, "hh:mm:ss tt")>
    <cfquery name="GetTeachersDetail">
        EXEC GetTeachersDetails @currentTeacherId="#session.userDetail.userId#"
    </cfquery>

    <cfquery name="GetTeachersEmail" datasource="ColdFusion">
    
        Select Email from Auth where UserId='#session.userDetail.userId#'
    </cfquery>
    <cfquery name="GetStudentsDetail">
        EXEC GetStudentsDetails
    </cfquery>
    <cfquery name="GetCoursesDetail">
        Select CourseName from Courses;
    </cfquery>
    <cfquery name="GetAdminsDetail">
        Select AdminName , Email , PhoneNumber from AdminDetail;
    </cfquery>
    <cfquery name="GetTeacherTeachingCourses">
        EXEC GetTeacherTeachingCourses @teacherId = '#session.userDetail.userId#';
    </cfquery>
    <cfquery name="RemainAllCourses">
    
        SELECT CourseName,CourseId
        FROM Courses
        WHERE CourseName NOT IN (
        SELECT C.CourseName
        FROM TeacherDetail TD
        JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
        JOIN Courses C ON TI.CourseID = C.CourseID
        WHERE TD.TeacherID = <cfqueryparam value="#session.userDetail.userId#" 
                  cfsqltype="CF_SQL_VARCHAR">
        )
        ORDER BY CourseName ASC;
    </cfquery>
    <!---Fetching Ends--->
    <!---Personal Detail Box --->
    <div class="d-flex align-items-center justify-content-center">
    <div class="personal-data-container mt-4">
    <h2 class="mb-3 text-center">
    Personal Information
    </h2>
    <p class="mb-1">
    <strong>
    Name:
    </strong>
    <cfoutput>#session.userDetail.userName#</cfoutput>
    </p>
    <p class="mb-1">
    <strong>
    Role:
    </strong>
    <cfoutput>#session.userDetail.role#</cfoutput>
    </p>
    <cfset rowNumber = 1>
    <cfif GetTeacherTeachingCourses.recordCount gt 0>
    
        <strong>
        Teaching Courses : 
        </strong>
        <br>
        <cfoutput query="GetTeacherTeachingCourses">
            Course 
            <span class="fw-bold">#rowNumber#
            </span>: #GetTeacherTeachingCourses.CourseName#
            <br>
            <cfset rowNumber += 1>
        </cfoutput>
    <cfelse>
        <!---No Course To Show --->
    </cfif>
    </div>
    </div>
    <!---Personal Box End --->
    <!---Enrolled Data Form Start --->
    <form method="post" class="mt-4">
    <h2 class="text-center">
    Teaching Courses:
    </h2>
    <div class="container">
    <div class="row">
    <cfoutput query="GetTeacherTeachingCourses">
        <div class="col-md-4">
        <div class="form-check">
        <input class="form-check-input" type="checkbox" name="selectedCourses" 
               value="#GetTeacherTeachingCourses.CourseName#" checked>
        <label class="form-check-label">#GetTeacherTeachingCourses.CourseName#
        </label>
        </div>
        </div>
    </cfoutput>
    <cfoutput query="RemainAllCourses">
        <div class="col-md-4">
        <div class="form-check">
        <input class="form-check-input" type="checkbox" name="selectedCourses" 
               value="#RemainAllCourses.CourseName#">
        <label class="form-check-label">#RemainAllCourses.CourseName#
        </label>
        </div>
        </div>
    </cfoutput>
    </div>
    <div class="d-flex justify-content-center">
    <button type="submit" name="updateTeacherCourses" class="btn btn-primary mt-3">
    Update
    </button>
    </div>
    </div>
    </form>
    <!---Enrolled Data Form End --->
    <!---Enrolled Data Logic Start --->
    <cfif structKeyExists(form, 'updateTeacherCourses')>
    
        <cfparam name="form.selectedCourses" default=''>
        <cfset selectedCoursesList = listToArray(form.selectedCourses)>
        <!---Sending Email to UnEnroll Course Teachers --->
        <cfloop query="GetTeacherTeachingCourses">
            <cfset unenrolledCourse = GetTeacherTeachingCourses.CourseName>
            <cfif not arrayFind(selectedCoursesList, unenrolledCourse)>
                <cfquery name="GetCourseTeachersEmails">
                    EXEC GetCourseTeachersEmails @courseName=<cfqueryparam value="#unenrolledCourse#" 
                              cfsqltype="CF_SQL_VARCHAR">
                </cfquery>
                <cfparam name="GetCourseTeachersEmails.TeacherEmails" default="">
                <cfset teacherEmails = GetCourseTeachersEmails.TeacherEmails>
                <!--- Only send email if there are teachers for this course --->
                <cftry>
                    <cfset emailArray = listToArray(teacherEmails)>
                    <cfset message = utils.sendEmail(emailArray, GetTeachersEmail.email, "Teacher Unenrollment Notification", "session.userDetail.userName (Teacher) has stopped teaching the course: 
						#unenrolledCourse#", "true")>
                
                <cfcatch type="any">
                    <p class="alert alert-danger">
                    An error occurred while sending the email(s). Please try
                    again.
                    </p>
                    <!---add a log --->
                </cfcatch>
                </cftry>
            </cfif>
        </cfloop>
        <!---Seding Email End --->
        <!---Delete --->
        <cfquery name="UnselectedCourses">
            SELECT TI.CourseID,C.CourseName as CourseName
            FROM TeacherInfo TI
            LEFT JOIN Courses C ON TI.CourseID = C.CourseID
            WHERE TI.TeacherID = <cfqueryparam value="#session.userDetail.userId#" 
                      cfsqltype="CF_SQL_VARCHAR">
            AND TI.CourseID NOT IN (<cfqueryparam value="#ArrayToList(selectedCoursesList)#" 
                      cfsqltype="CF_SQL_VARCHAR" list="true">
            )
        </cfquery>
        <cfloop query="UnselectedCourses">
            <cfset courseName = UnselectedCourses.CourseName>
            <cfif arrayFindNoCase(selectedCoursesList, courseName) eq 0>
                <cfquery name="DeleteUnselectedCourse">
                    DELETE FROM TeacherInfo
                    WHERE TeacherID = <cfqueryparam value="#session.userDetail.userId#" 
                              cfsqltype="CF_SQL_VARCHAR">
                    AND CourseID = <cfqueryparam value="#UnselectedCourses.CourseID#" 
                              cfsqltype="CF_SQL_VARCHAR">
                </cfquery>
                <cfset message = "#session.userDetail.userName# has Stopped Teaching #UnselectedCourses.CourseName# at #currentDate# , #currentTime#">
                <cflog type="any" file="logs" text="#message#"><!---Do it  --->
            </cfif>
        </cfloop>
    
        <!---ADD --->
        <cfif ArrayLen(selectedCoursesList) neq 0>
            <cfloop array="#selectedCoursesList#" index="selectedCourse">
                <cfset courseFound = false>
                <cfloop query="GetTeacherTeachingCourses">
                    <cfif GetTeacherTeachingCourses.CourseName eq selectedCourse>
                        <cfset courseFound = true>
                        <cfbreak>
                    </cfif>
                </cfloop>
                <cfif not courseFound>
                    <cfquery name="InsertTeacherInfo">
                        INSERT INTO TeacherInfo (TeacherID, CourseID)
                        SELECT<cfqueryparam value="#session.userDetail.userId#" 
                                  cfsqltype="CF_SQL_VARCHAR">
                        AS TeacherID,
                        CourseId
                        FROM Courses
                        WHERE CourseName = <cfqueryparam value="#selectedCourse#" 
                                  cfsqltype="CF_SQL_VARCHAR">
                    </cfquery>
                    <cfset message = "#session.userDetail.userName# has Started Teaching #selectedCourse#  at #currentDate# , #currentTime#">
                    <cflog type="any" file="logs" text="#message#">
                </cfif>
            </cfloop>
        <cfelse>
            <!---               no course to display in personal data
            --->
        </cfif>
    
        <cflocation url="index.cfm">
    </cfif>

    <!---Enrolled Data Logic End --->
    <!---Fellow Staff Detail--->
    <div class="container mt-5">
    <h2 class="text-center">
    Fellow Teachers Detail:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-dark">
    <tr>
    <th scope="col">
    Sr. No.
    </th>
    <th scope="col">
    Teacher Name
    </th>
    <th scope="col">
    Teaching Courses
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetTeachersDetail">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetTeachersDetail.TeacherName#
        </td>
        <cfif GetTeachersDetail.CourseNames neq ''>
            <td>
            #GetTeachersDetail.CourseNames#
            </td>
        <cfelse>
            <td class="text-danger">
            None
            </td>
        </cfif>
        </tr>
        <cfset rowNumber++>
    </cfoutput>
    </tbody>
    </table>
    </div>
    <!---Student Detail --->
    <div class="container mt-5">
    <h2 class="text-center">
    Students Detail:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-dark">
    <tr>
    <th scope="col">
    Sr. No.
    </th>
    <th scope="col">
    Student Name
    </th>
    <th scope="col">
    Learning Courses
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetStudentsDetail">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetStudentsDetail.StudentName#
        </td>
        <cfif GetStudentsDetail.CourseNames neq ''>
            <td>
            #GetStudentsDetail.CourseNames#
            </td>
        <cfelse>
            <td class="text-danger">
            None
            </td>
        </cfif>
        </tr>
        <cfset rowNumber++>
    </cfoutput>
    </tbody>
    </table>
    </div>
    <!---Available Courses --->
    <div class="container mt-5">
    <h2 class="text-center">
    Available Courses:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-dark">
    <tr>
    <th scope="col">
    Sr. No.
    </th>
    <th scope="col">
    Course Name
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetCoursesDetail">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetCoursesDetail.CourseName#
        </td>
        </tr>
        <cfset rowNumber++>
    </cfoutput>
    </tbody>
    </table>
    </div>
    <!---admin details --->
    <div class="container mt-5">
    <h2 class="text-center">
    Admin Detail:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-dark">
    <tr>
    <th scope="col">
    Sr. No.
    </th>
    <th scope="col">
    Name
    </th>
    <th scope="col">
    Email
    </th>
    <th scope="col">
    Phone Number
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetAdminsDetail">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetAdminsDetail.AdminName#
        </td>
        <td>#GetAdminsDetail.Email#
        </td>
        <td>#GetAdminsDetail.phoneNumber#
        </td>
        </tr>
        <cfset rowNumber++>
    </cfoutput>
    </tbody>
    </table>
    <hr>
    <!---Filter Functionality --->
    <div class="container mt-4">
    <h2 class="text-center">
    Name Filter
    </h2>
    <form method="post" name="filterForm" class="mt-3">
    <div class="d-flex align-items-center justify-content-center">
    <div class="form-group">
    <label for="userName">
    <strong>
    Username
    <span class="h5 text-danger">
    *
    </span>
    :
    </strong>
    </label>
    <input type="text" required="yes" name="userName" placeholder="Enter a UserName"
           class="form-control">
    </div>
    <button type="submit" name="filterSubmitWithName" class=" mx-3 mt-4 btn btn-primary">
    Submit
    </button>
    </div>
    </form>
    </div>
    <cfif structKeyExists(form, 'filterSubmitWithName')>
        <cfparam name="form.userName" default="C">
        <cfset courseId = form.userName>
    
        <cfquery name="fetchUserDataForName">
            SELECT 'Student' AS UserType, SD.StudentName AS Name, COALESCE(C.CourseName, 'Not
            Enrolled') AS Course
            FROM StudentDetail SD
            LEFT JOIN StudentInfo SI ON SD.StudentID = SI.StudentID
            LEFT JOIN Courses C ON SI.CourseID = C.CourseID
            WHERE SD.StudentName LIKE <cfqueryparam value="%#form.userName#%" 
                      cfsqltype="CF_SQL_VARCHAR">
            UNION
            SELECT 'Teacher' AS UserType, TD.TeacherName AS Name, COALESCE(C2.CourseName, 'Not
            Teaching') AS Course
            FROM TeacherDetail TD
            LEFT JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
            LEFT JOIN Courses C2 ON TI.CourseID = C2.CourseID
            WHERE TD.TeacherName LIKE <cfqueryparam value="%#form.userName#%" 
                      cfsqltype="CF_SQL_VARCHAR">
        
        </cfquery>
    
        <div class="container mt-2">
        <cfif fetchUserDataForName.recordCount neq 0>
            <table class="table table-bordered">
            <thead class="thead-dark">
            <tr>
            <th scope="col">
            User Type
            </th>
            
            <th scope="col">
            Name
            </th>
            <th scope="col">
            Course Name
            </th>
            </tr>
            </thead>
            <tbody>
            <cfoutput query="fetchUserDataForName">
                <tr>
                <td>#fetchUserDataForName.UserType#
                </td>
                
                <td>#fetchUserDataForName.Name#
                </td>
                <td>#fetchUserDataForName.Course#
                </td>
                </tr>
            </cfoutput>
        <cfelse>
            <p class="text-center text-danger">
            No User with Name 
            <cfoutput>#form.userName#</cfoutput>
            </p>
            </tbody>
            </table>
        </cfif>
        </div>
    </cfif>
<cfelse>
    <!---Tag End Part --->
</cfif>
    </div>
</body>
</body>
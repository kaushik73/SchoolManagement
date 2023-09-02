<!DOCTYPE html>
<html lang="en">
<head>
<link rel="stylesheet" href="../style.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
      crossorigin="anonymous">
<title>
Student View
</title>
</head>
<body>
<cfif thisTag.executionMode eq 'start'>
    <cfset utils = createObject('component', 'finalAssignment.components.utils')>
    <cfset codeWords = utils.getCodeWords()>
    <cfset currentDateAndTime = now()>
    <cfset currentDate = dateFormat(currentDateAndTime, "mm/dd/yyyy")>
    <cfset currentTime = timeFormat(currentDateAndTime, "hh:mm:ss tt")>
    <!---Start of Fetching --->
    <cfquery name="studentsDetail">
        select * from StudentDetail;
    </cfquery>
    <cfquery name="GetTeachersDetails">
        EXEC GetTeachersDetails @searchPattern = NULL
    </cfquery>
    <cfquery name="GetCoursesDetail">
        Select CourseName,CourseId from Courses;
    </cfquery>
    <cfquery name="GetGuardianEmail">
        Select GuardianEmail from StudentDetail where StudentID='#session.userDetail.userId#';
    </cfquery>
    <cfquery name="GetTeachersPersonalDetails">
        Select TeacherName , Email, PhoneNumber from TeacherDetail;
    </cfquery>
    <cfquery name="GetStudentEmail" datasource="ColdFusion">
        Select Email from Auth where UserId='#session.userDetail.userId#'
    </cfquery>
    <cfquery name="GetStudentEnrollCourses">
        EXEC GetStudentEnrollCourses @studentId = '#session.userDetail.userId#';
    </cfquery>
    <cfquery name="RemainAllCourses">
    
        SELECT CourseName,CourseId
        FROM Courses
        WHERE CourseName NOT IN (
        SELECT C.CourseName
        FROM StudentDetail SD
        JOIN StudentInfo SI ON SD.StudentID = SI.StudentID
        JOIN Courses C ON SI.CourseID = C.CourseID
        WHERE SD.StudentID = <cfqueryparam value="#session.userDetail.userId#" 
                  cfsqltype="CF_SQL_VARCHAR">
        )
        ORDER BY CourseName ASC;
    </cfquery>
    <!---End of Fetching  --->
    <!---Personal Box (Student Data) --->
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
    <cfif GetStudentEnrollCourses.recordCount gt 0>
        <div class="enrolled-courses">
        <span>
        <strong>
        Enrolled Courses:
        </strong>
        <span>
    
        <ul class="list-unstyled">
        <cfset rowNumber = 1>
        <cfoutput query="GetStudentEnrollCourses">
            <li>Course
            <span class="fw-bold">#rowNumber#
            </span>:#GetStudentEnrollCourses.CourseName#
            </li>
            <cfset rowNumber += 1>
        </cfoutput>
        </ul>
    <cfelse>
        <!---No Course To Display --->
    </cfif>
        </div>
    </div>
    </div>
    <!---Personal Box End --->
    <!---Enrolled Data Form Start --->
    <form method="post" class="mt-4">
    <h2 class="text-center">
    Current Enrolled Courses:
    </h2>
    <cfif structkeyexists(url, 'x') and URL.x eq codeWords.courseLimitExceed>
        <h5 class="text-center text-danger">
        You Can Only Enroll in Maximum 3 Courses 
        <sup>
        <a class="ml-2 mb-1 h3 text-primary close text-decoration-none  " 
           href="/finalAssignment/index.cfm">
        &times;
        </a>
        </sup>
        </h5>
    </cfif>
    <div class="container">
    <div class="row">
    <cfoutput query="GetStudentEnrollCourses">
        <div class="col-md-4">
        <div class="form-check">
        <input class="form-check-input" type="checkbox" name="selectedCourses" 
               value="#GetStudentEnrollCourses.CourseName#" checked>
        <label class="form-check-label">#GetStudentEnrollCourses.CourseName#
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
    <button type="submit" name="updateStudentCourses" class="btn btn-primary mt-3">
    Update
    </button>
    </div>
    </div>
    </form>
    <!---Enrolled Data Form End --->
    <!---Enrolled Data Logic Start --->
    <cfif structKeyExists(form, 'updateStudentCourses')>
        <cfparam name="form.selectedCourses" default="">
        <cfset selectedCoursesList = listToArray(form.selectedCourses)>
        <!---Sending Email to UnEnroll Course Teachers --->
        <cfloop query="GetStudentEnrollCourses">
            <cfset unenrolledCourse = GetStudentEnrollCourses.CourseName>
            <cfif not arrayFind(selectedCoursesList, unenrolledCourse)>
                <cfquery name="GetCourseTeachersEmails">
                    EXEC GetCourseTeachersEmails @courseName=<cfqueryparam value="#unenrolledCourse#" 
                              cfsqltype="CF_SQL_VARCHAR">
                </cfquery>
            
                <cfset teacherEmails = GetCourseTeachersEmails.TeacherEmails>
                <cftry>
                    <cfparam name="teacherEmails" default="">
                    <cfset emailArray = listToArray(teacherEmails)>
                    <cfset arrayAppend(emailArray, GetStudentEmail.Email)>
                    <cfset arrayAppend(emailArray, GetGuardianEmail.GuardianEmail)>
                    <cfset message = utils.sendEmail(emailArray, GetStudentEmail.email, "Student Unenrollment Notification", " #session.userDetail.userName#(Student) has unenrolled from the course: 
						#unenrolledCourse#", "true")>
                
                <cfcatch type="any">
                    <p class="alert alert-danger">
                    An error occurred while sending the email(s). Please try
                    again.
                    </p>
                </cfcatch>
                </cftry>
            </cfif>
        </cfloop>
        <!---Seding Email End --->
        <!---Delete --->
        <cfquery name="UnselectedCourses">
            SELECT SI.CourseID,C.CourseName as CourseName
            FROM StudentInfo SI
            LEFT JOIN Courses C ON SI.CourseID = C.CourseID
            WHERE SI.StudentID = <cfqueryparam value="#session.userDetail.userId#" 
                      cfsqltype="CF_SQL_VARCHAR">
            AND SI.CourseID NOT IN (<cfqueryparam value="#ArrayToList(selectedCoursesList)#" 
                      cfsqltype="CF_SQL_VARCHAR" list="true">
            )
        </cfquery>
        <cfloop query="UnselectedCourses">
            <cfset courseName = UnselectedCourses.CourseName>
            <cfif arrayFindNoCase(selectedCoursesList, courseName) eq 0>
                <cfquery name="DeleteUnselectedCourse">
                    DELETE FROM StudentInfo
                    WHERE StudentID = <cfqueryparam value="#session.userDetail.userId#" 
                              cfsqltype="CF_SQL_VARCHAR">
                    AND CourseID = <cfqueryparam value="#UnselectedCourses.CourseID#" 
                              cfsqltype="CF_SQL_VARCHAR">
                </cfquery>
                <cfset message = "#session.userDetail.userName# has Unenroll From #UnselectedCourses.CourseName# at #currentDate# , #currentTime#">
                <cflog type="any" file="logs" text="#message#">
            </cfif>
        </cfloop>
    
        <!---ADD --->
        <cfif selectedCoursesList.len() lt 4>
            <cftry>
                <cfloop array="#selectedCoursesList#" index="selectedCourse">
                    <cfset courseFound = false>
                    <cfloop query="GetStudentEnrollCourses">
                        <cfif GetStudentEnrollCourses.CourseName eq selectedCourse>
                            <cfset courseFound = true>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                    <cfif not courseFound>
                        <cfquery name="InsertStudentInfo">
                            INSERT INTO StudentInfo (StudentID, CourseID)
                            SELECT<cfqueryparam value="#session.userDetail.userId#" 
                                      cfsqltype="CF_SQL_VARCHAR">
                            AS StudentID,
                            CourseId
                            FROM Courses
                            WHERE CourseName = <cfqueryparam value="#selectedCourse#" 
                                      cfsqltype="CF_SQL_VARCHAR">
                        </cfquery>
                    
                        <cfset message = "#session.userDetail.userName# has Enroll To #selectedCourse#  at #currentDate# , #currentTime#">
                        <cflog type="any" file="logs" text="#message#">
                    </cfif>
                </cfloop>
                <cflocation url="index.cfm">
            <cfcatch type="any">
                <p>
                Error While Enrolling in Course, Please Try Again!
                </p>
            </cfcatch>
            </cftry>
        <cfelse>
            <!---Selected more than 3 --->
            <cflocation url="/finalAssignment/index.cfm?x=#codeWords.courseLimitExceed#">
        </cfif>
    </cfif>

    <!---Enrolled Data Logic End --->
    <!---Current Teacher Teaching Enrolled Subjects --->
    <div class="container mt-4">
    <cfif GetStudentEnrollCourses.recordCount neq 0>
        <h2 class="text-center">
        Current Teachers Teaching Enrolled Subjects:
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
        <th scope="col">
        Teachers
        </th>
        </tr>
        </thead>
        <tbody>
        <cfoutput>
        
            <cfset rowNum = 1>
            <cfloop query="GetStudentEnrollCourses">
                <cfquery name="GetCourseTeachers">
                    Exec GetCourseTeachers @courseName='#GetStudentEnrollCourses.CourseName#'
                </cfquery>
                <tr>
                <td>
                #rowNum#
                </td>
                <td>
                #GetStudentEnrollCourses.CourseName#
                </td>
                <cfif GetCourseTeachers.TeacherList neq ''>
                    <td>
                    #GetCourseTeachers.TeacherList#
                    </td>
                <cfelse>
                    <td class="text-danger">
                    None
                    </td>
                </cfif>
                </tr>
                <cfset rowNum++>
            </cfloop>
        </cfoutput>
        </tbody>
        </table>
    </cfif>
    </div>
    <!---Teacher Teaching Courses --->
    <div class="container mt-4">
    <h2 class="text-center">
    Teacher Teaching Courses:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-dark">
    <tr>
    <th>
    Sr. No.
    </th>
    <th>
    Teacher Name
    </th>
    <th>
    Teaching Courses
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetTeachersDetails">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetTeachersDetails.TeacherName#
        </td>
        <cfif GetTeachersDetails.CourseNames neq ''>
            <td>
            #GetTeachersDetails.CourseNames#
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
    <!---Teacher Personal Details --->
    <div class="container mt-4">
    <h2 class="text-center">
    Teacher Personal Detail:
    </h2>
    <table class="table table-bordered">
    <thead class="thead-light">
    <tr>
    <th>
    Sr. No.
    </th>
    <th>
    Name
    </th>
    <th>
    Email
    </th>
    <th>
    Phone Number
    </th>
    </tr>
    </thead>
    <tbody>
    <cfset rowNumber = 1>
    <cfoutput query="GetTeachersPersonalDetails">
        <tr>
        <td>#rowNumber#
        </td>
        <td>#GetTeachersPersonalDetails.TeacherName#
        </td>
        <td>#GetTeachersPersonalDetails.Email#
        </td>
        <td>#GetTeachersPersonalDetails.phoneNumber#
        </td>
        </tr>
        <cfset rowNumber++>
    </cfoutput>
    </tbody>
    </table>
    </div>
<cfelse>
    <!---Tag End Part --->
</cfif>
</body>
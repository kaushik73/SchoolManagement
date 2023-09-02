<!DOCTYPE html>
<html lang="en">
<head>
	<link rel="stylesheet" href="../style.css">
	<title>
		Admin View
	</title>
</head>
<body>
	<cfset utils = createObject('component', 'finalAssignment.components.utils')>
	<cfif thisTag.executionMode eq 'start'>
		<cfquery name="GetTeachersDetail">
			EXEC GetTeachersDetails
		</cfquery>
		<cfquery name="GetTeacherPersonalInfo" datasource="coldFusion">
			select email , password from auth where USERID like 't%'
		</cfquery>
				<cfquery name="GetStudentPersonalInfo" datasource="coldFusion">
			select email , password from auth where USERID like 's%'
		</cfquery>
		<cfquery name="GetStudentsDetail">
			EXEC GetStudentsDetails
		</cfquery>
		<cfquery name="GetCoursesDetail">
			Select CourseName from Courses;
		</cfquery>
		<cfquery name="GetAdminsDetail">
			Select AdminName , Email ,PhoneNumber from AdminDetail;
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
				<p class="mb-1">
					<strong>
						Phone Number:
					</strong>
					<cfoutput>#session.userDetail.phoneNumber#</cfoutput>
				</p>
			</div>
		</div>
		<!---Personal Box End --->
		<!---All Teacher Detail--->
		<div class="container mt-5">
		    <h2 class="text-center">
		        All Teachers Detail:
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
		                <th scope="col">
		                    Email
		                </th>
		            </tr>
		        </thead>
		        <tbody>
		            <cfset rowNumber = 1>
		                <cfloop from="1" to="#max(GetTeachersDetail.RecordCount,GetTeacherPersonalInfo.RecordCount)#" index="i">                     
		   <cfoutput >         
		          <tr>
		                <td>
		                    #rowNumber#
		                </td>
		                 <td>
					        <cfif i lte GetTeachersDetail.RecordCount>
					            #GetTeachersDetail.TeacherName[i]#
					        </cfif>
		   				 </td>
		    			<td>
					        <cfif i lte GetTeachersDetail.RecordCount>
					            #GetTeachersDetail.CourseNames[i]#
					        </cfif>
		    			</td>
						<td>
					        <cfif i lte GetTeacherPersonalInfo.RecordCount>
					            #GetTeacherPersonalInfo.email[i]#
					        </cfif>
		    			</td>
		            </tr>
		            <cfset rowNumber++>
					</tr>
		</cfoutput></cfloop>       
		 </tbody>
		    </table>
		</div>
		<!---Student Detail --->
		<div class="container mt-5">
			<h2 class="text-center">
				All Students Detail:
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
						<th scope="col">
							Email
						</th>
					</tr>
				</thead>
				<tbody>
		            <cfset rowNumber = 1>
		                <cfloop from="1" to="#max(GetStudentsDetail.RecordCount, GetStudentPersonalInfo.RecordCount)#" index="i">           
		             <cfoutput >
		                    
		                <tr>
		                <td>
		                    #rowNumber#
		                </td>
		                 <td>
		        <cfif i lte GetStudentsDetail.RecordCount>
		            #GetStudentsDetail.StudentName[i]#
		        </cfif>
		    </td>
		    		                 <td>
		        <cfif i lte GetStudentsDetail.RecordCount>
		            #GetStudentsDetail.CourseNames[i]#
		        </cfif>
		    </td>
		                             <td>
		        <cfif i lte GetStudentPersonalInfo.RecordCount>
		            #GetStudentPersonalInfo.email[i]#
		        </cfif>
		    </td>
		            </tr>
		            <cfset rowNumber++>
		</tr>
		</cfoutput></cfloop>        </tbody>
			</table>
		</div>
		
		<!---Available Courses --->
		<div class="container mt-5">
			<h2 class="text-center">
				All Available Courses:
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
							<td>
								#rowNumber#
							</td>
							<td>
								#GetCoursesDetail.CourseName#
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
							<td>
								#rowNumber#
							</td>
							<td>
								#GetAdminsDetail.AdminName#
							</td>
							<td>
								#GetAdminsDetail.Email#
							</td>
							<td>
								#GetAdminsDetail.phoneNumber#
							</td>
						</tr>
						<cfset rowNumber++>
					</cfoutput>
				</tbody>
			</table>
		</div>
		
		
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
								Username<span class="h5 text-danger">*</span>:
							</strong>
						</label>
						<input type="text" required="yes" name="userName" placeholder="Enter a UserName" class="form-control">
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
				SELECT 'Student' AS UserType, SD.StudentName AS Name, COALESCE(C.CourseName, 'Not Enrolled') AS Course
        FROM StudentDetail SD
        LEFT JOIN StudentInfo SI ON SD.StudentID = SI.StudentID
        LEFT JOIN Courses C ON SI.CourseID = C.CourseID
        WHERE SD.StudentName LIKE <cfqueryparam value="%#form.userName#%" cfsqltype="CF_SQL_VARCHAR">
        UNION
        SELECT 'Teacher' AS UserType, TD.TeacherName AS Name, COALESCE(C2.CourseName, 'Not Teaching') AS Course
        FROM TeacherDetail TD
        LEFT JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
        LEFT JOIN Courses C2 ON TI.CourseID = C2.CourseID
        WHERE TD.TeacherName LIKE <cfqueryparam value="%#form.userName#%" cfsqltype="CF_SQL_VARCHAR">
  
			</cfquery>
	
			<div class="container mt-2">
						<cfif fetchUserDataForName.recordCount neq 0 >
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
								<td>
									#fetchUserDataForName.UserType#
								</td>
								
								<td>
									#fetchUserDataForName.Name#
								</td>
								<td>
									#fetchUserDataForName.Course#
								</td>
							</tr>
						</cfoutput>
						<cfelse>
						<p class="text-center text-danger">No User with Name <cfoutput>#form.userName#</cfoutput></p>
						
					</tbody>
				</table>	
				</cfif>
				</div>
		</cfif>
	<cfelse>
		<!---Tag End Part --->
	</cfif>
</body>
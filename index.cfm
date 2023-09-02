<!DOCTYPE html>
<html lang="en">
<head>
	<link rel="stylesheet" href="style.css">
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
	      rel="stylesheet" 
	      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
	      crossorigin="anonymous">
	<title>
		Final Assignment
	</title>
</head>
<body>
	<cfif not isDefined("session.userDetail")>
		<cf_pagenotfound>
	<cfelse>
		<cfset utils = createObject('component', 'finalAssignment.components.utils')>
		<cfset codeWords = utils.getCodeWords()>
		<nav class="navbar navbar-light bg-light">
			<div class="main-heading">
			<cf_header pagetitle="School Management System" >
			</div>
			<div class="navigation-bar-buttons">
				
			<ul class="navbar-nav ml-auto">
				<li class=" nav-item d-flex align-items-center">
					<a class="navigation-link" 
					   href="/finalAssignment/auth/login.cfm?<cfoutput>x=#codeWords.logout#</cfoutput>">
						<h5>
							log-out
						</h5>
					</a>
					<span class="mx-2">
						<h3>
							| 
						</h3>
					</span>
					<a class="navigation-link" href="profile.cfm">
						<h5>
							Profile
						</h5>
					</a>
				</li>
			</ul>
			</div>
		</nav>
		
		<cfset role = "#session.userDetail.role#">
		<cfif role eq 'student'>
			<cf_studentview>
			</cf_studentview>
		<cfelseif role eq 'teacher'>
			<cf_teacherview>
			</cf_teacherview>
		<cfelseif role eq 'admin'>
			<cf_adminview>
			</cf_adminview>
		<cfelse>
			<p class="text-danger">
				Some Error Occured, Please Login Again
			</p>
		</cfif>
		<hr>
		<!---Filter Functionality --->
		<div class="container mt-4">
			<h2 class="text-center">
				Course Filter
			</h2>
			<form method="post" name="filterForm" class="mt-3" >
				<div class="d-flex align-items-center justify-content-center">
					<div class="mx-3 form-group">
						<label for="course">
							<strong>
								Select a Course<span class="h5 text-danger">*</span>:
							</strong>
						</label>
						<select name="course" class="form-control" required="true">
							<cfquery name="courseData">
								SELECT CourseId, CourseName
								FROM Courses order by CourseName 
							</cfquery>
							<option  disabled="true" selected="true" value="">
								Select a Course
							</option>
							<cfoutput query="courseData">
								<option value="#courseData.CourseId#">
									#courseData.CourseName#
								</option>
							</cfoutput>
						</select>
					</div>
					
					<button type="submit" name="filterSubmit" class="mt-4 btn btn-primary">
						Submit
					</button>
				</div>
			</form>
		</div>

		
		<cfif structKeyExists(form, 'filterSubmit')>
			<cfparam name="form.course" default="C">
			<cfset courseId = form.course>
		
			<cfquery name="fetchUserData">
				SELECT 'Student' AS UserType, SD.StudentName AS Name
				FROM StudentDetail SD
				INNER JOIN StudentInfo SI ON SD.StudentID = SI.StudentID
				WHERE SI.CourseID = <cfqueryparam value="#form.course#" cfsqltype="CF_SQL_VARCHAR">
				UNION
				SELECT 'Teacher' AS UserType, TD.TeacherName AS Name
				FROM TeacherDetail TD
				INNER JOIN TeacherInfo TI ON TD.TeacherID = TI.TeacherID
				WHERE TI.CourseID = <cfqueryparam value="#form.course#" cfsqltype="CF_SQL_VARCHAR">
			
			</cfquery>
		
			<cfquery name="GetCourseName">
				select CourseName from Courses where CourseId = <cfqueryparam value="#form.course#" cfsqltype="CF_SQL_VARCHAR">
			
			</cfquery>
			<div class="container mt-2">
										<cfif fetchUserData.recordCount neq 0 >

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
						<cfoutput query="fetchUserData">
							<tr>
								<td>
									#fetchUserData.UserType#
								</td>
								
								<td>
									#fetchUserData.Name#
								</td>
								<td>
									#GetCourseName.courseName#
								</td>
							</tr>
						</cfoutput>
					</tbody>
				</table>
				<cfelse>
					<p class="text-center text-danger">No User with Name #form.userName#</p>

				</cfif>
			</div>
		</div>
		</cfif>
	</cfif>
	<div class="empty-div" style="height: 150px;">						
</body>
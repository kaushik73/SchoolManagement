<!DOCTYPE html>
<html lang="en">
<head>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
      crossorigin="anonymous">

<link rel="stylesheet" href="style.css">
<title>
My Profile
</title>
<script src="https://kit.fontawesome.com/c736ccd8d8.js" crossorigin="anonymous">
</script>
</head>
<body>
<cfif not isDefined("session.userDetail")>
    <cf_pagenotfound>
<cfelse>
    <cfset utils = createObject('component', 'finalAssignment.components.utils')>
    <cfset codeWords = utils.getCodeWords()>
    <cfquery name="authData" datasource="ColdFusion">
        SELECT Email, Password
        FROM Auth
        WHERE UserId = <cfqueryparam value="#session.userDetail.userId#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    <cfquery name="studentsAndFellowTeachersEmail" datasource="ColdFusion">
        SELECT Email
        FROM Auth
        WHERE RoleId Not in (SELECT RoleId FROM Role WHERE Type = 'admin')
        AND (UserId != <cfqueryparam value="#session.userDetail.userId#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>

    <cf_header pagetitle="My Profile" class="text-center">
    </cf_header>
    <div class="form mt-2">
    <cfparam name="URL.x" default="">
    <cfif URL.x eq codeWords.updated>
        <p class="text-success">
        Profile Updated SuccessFully!
        </p>
    <cfelseif URL.x eq codeWords.noChange>
        <p class="text-danger">
        No Changes are Done!
        </p>
    </cfif>
    <cfform method="post" action="/finalAssignment/profile.cfm" class="mt-4">
        <div class="form-group">
        <label for="name">
        Name:
        </label>
        <cfinput required="true" type="text" class="form-control" name="name"
                 value="#session.userDetail.userName#" placeholder="Enter your name">
        </div>
        <div class="form-group">
        <label for="email">
        Email:
        </label>
        <cfinput required="true" type="email" class="form-control" name="email"
                 value="#authData.Email#" placeholder="Enter your email">
        </div>
        <div class="form-group">
        <label for="password">
        Password:
        </label>
        <div class="input-group">
        <cfinput minlength="6" required="true" type="password" class="form-control"
                 name="password" value="#authData.password#" placeholder="Enter your password">
        <div class="input-group-append">
        <button class="btn btn-outline-secondary" type="button" id="showPasswordButton">
        <i class="fa fa-regular fa-eye" id="eyeIcon">
        </i>
        </button>
        </div>
        </div>
        </div>
        <div class="form-group">
        <label for="phoneNumber">
        Phone Number
        </label>
        <cfinput required="true" type="text" class="form-control" name="phoneNumber"
                 pattern="[1-9]{1}[0-9]{9}" maxlength="10" minlength="10" 
                 value='#session.userDetail.phoneNumber#' placeholder="Enter your phone number">
        </div>
        <cfif session.userDetail.role eq "student">
            <div class="form-group">
            <label for="guardianEmail">
            Guardian Email
            </label>
            <cfinput required="true" type="email" class="form-control" name="guardianEmail"
                     value="#session.userDetail.guardianEmail#" placeholder="Enter guardian's email">
            </div>
        </cfif>
    
        <cfinput type="hidden" name="userId" value="#session.userDetail.userId#">
        <div class="form-group text-center mt-2">
        <button type="submit" name="updateProfile" class="btn btn-primary">
        Update
        </div>
        </button>
        <div class="mt-2 d-flex align-items-center justify-content-between">
        <a href="/finalAssignment/index.cfm" class="navigation-link">
        <h5>
        Dashboard
        </h5>
        </a>
        <a href="/finalAssignment/auth/login.cfm?x=<cfoutput>#codeWords.logout#</cfoutput>" 
           class="navigation-link">
        <h5>
        log-out
        </h5>
        </a>
        </div>
    </cfform>
    </div>
    <cfif structKeyExists(form, 'updateProfile')>
        <cfparam name="form.guardianEmail" default="">
    
        <cfscript>
            oldDetailsOfUser = StructNew();
            oldDetailsOfUser.email = "#authData.Email#";
            oldDetailsOfUser.password = "#authData.Password#";
            oldDetailsOfUser.userName = "#session.userDetail.userName#";
            oldDetailsOfUser.phoneNumber = "#session.userDetail.phoneNumber#";
            if(session.userDetail.role eq "student")
            {
                oldDetailsOfUser.guardianEmail = "#session.userDetail.guardianEmail#";
            }
            else
            {
                oldDetailsOfUser.guardianEmail = '';
            }
        </cfscript>
        
        <cfset noChanges = true>
        <cfif form.email EQ oldDetailsOfUser.email AND form.password EQ oldDetailsOfUser.password 
              AND form.name EQ oldDetailsOfUser.userName AND form.phoneNumber EQ oldDetailsOfUser.phoneNumber 
              AND form.guardianEmail EQ oldDetailsOfUser.guardianEmail>
            <cflocation url="/finalAssignment/profile.cfm?x=#codeWords.noChange#">
        <cfelse>
            <!--- User make any changes --->
            <cfstoredproc procedure="editUserData" datasource="ColdFusion">
                <cfprocparam value="#form.userId#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam value="#form.password#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam variable="status1" type="out" cfsqltype="CF_SQL_VARCHAR">
            </cfstoredproc>
        
            <cfstoredproc procedure="editUserData">
                <cfprocparam value="#form.userId#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam value="#form.name#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam value="#form.phoneNumber#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam value="#form.guardianEmail#" cfsqltype="CF_SQL_VARCHAR">
                <cfprocparam variable="status2" type="out" cfsqltype="CF_SQL_VARCHAR">
            </cfstoredproc>
            <cfset authenticationService = createObject('component', 'finalAssignment.components.authService')>
            <cfset isUserLoggedIn = authenticationService.doLogin(form.email, form.password)/>
            <cfif status1 eq 0 or status2 eq 0>
                Some Error Occured, Please Try Again!
            <cfelse>
                <cfif session.userDetail.role eq 'student'>
                    <cftry>
                        <cfset toEmail = "#authData.Email#,#session.userDetail.guardianEmail#">
                        <cfset toEmail = ListToArray(toEmail)>
                        <cfset message = utils.sendEmail(toEmail, "#authData.Email#", "#session.userDetail.userName# Updated Profile", "Profile Updated SuccessFully", 'true')>
                    <cfcatch type="any">
                        <p class="alert alert-danger">
                        An error occurred while sending the email(s). Please try again.
                        </p>
                    </cfcatch>
                    </cftry>
                
                <cfelseif session.userDetail.role eq 'teacher'>
                    <cftry>
                    
                        <cfif form.email EQ oldDetailsOfUser.email OR form.phoneNumber EQ oldDetailsOfUser.phoneNumber>
                            <!---Phone or Email is Modified --->
                            <cfset emailArray = ValueList(studentsAndFellowTeachersEmail.Email)>
                            <cfset emailArray = listToArray(emailArray)>
                            <cfset message = utils.sendEmail(emailArray, "#authData.Email#", "#session.userDetail.userName# Updated Profile", "Profile Updated Successfully", "true")>
                        </cfif>
                    
                    <cfcatch type="any">
                        <p class="alert alert-danger">
                        An error occurred while sending the email(s). Please try
                        again.
                        </p>
                    </cfcatch>
                    </cftry>
                <cfelse>
                    <!---user is admin NO email sent --->
                </cfif>
                <cflocation url="/finalAssignment/profile.cfm?x=#codeWords.updated#">
            </cfif>
        </cfif>
    </cfif>

    <script>
    const passwordInput = document.querySelector('input[name="password"]');
    const eyeIcon = document.getElementById('eyeIcon');
    const showPasswordButton = document.getElementById('showPasswordButton');
    showPasswordButton.addEventListener('click', function () {
    if (passwordInput.type === 'password') {
    passwordInput.type = 'text';
    eyeIcon.className = 'fa fa-regular fa-eye-slash';
    } else {
    passwordInput.type = 'password';
    eyeIcon.className = 'fa fa-regular fa-eye';
    }
    });
    </script>
</cfif>
</body>
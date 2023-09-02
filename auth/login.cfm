<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="../style.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
      crossorigin="anonymous">

<title>
Final Assignment
</title>
<script src="https://kit.fontawesome.com/c736ccd8d8.js" crossorigin="anonymous">
</script>
</head>
<body>
<cfset utils = createObject('component', 'finalAssignment.components.utils')>
<cfset authenticationService = createObject('component', 'finalAssignment.components.authService')>
<cfset currentDateAndTime = now()>
<cfset codeWords = utils.getCodeWords()>
<cfset currentDate = dateFormat(currentDateAndTime, "mm/dd/yyyy")>
<cfset currentTime = timeFormat(currentDateAndTime, "hh:mm:ss tt")>
<cfparam name="URL.x" default="">

<cfif URL.x eq codeWords.cancel OR URL.x eq codeWords.logout>
    <cfset authenticationService = createObject('component', '/finalAssignment/components/authService').doLogout()/>
    <cflocation url="login.cfm">
</cfif>
<cf_header pagetitle="Login Form" class="text-center">
</cf_header>
<!---Form Start Here --->
<div class="form mt-4">
<cfif URL.x eq codeWords.invalidUser>
    <p class="text-danger">
    Invalid User, Please Try Again!
    </p>
</cfif>
<cfform>
    <div class="form-group">
    <label for="email">
    Email
    </label>
    <cfinput type="text" validate="email" name="email" class="form-control"
             placeholder="Email">
    </div>
    <div class="form-group">
    <label for="password">
    Password:
    </label>
    <div class="input-group">
    <cfinput minlength="6" required="true" type="password" class="form-control"
             name="password" placeholder="Enter your password">
    <div class="input-group-append">
    <button class="btn btn-outline-secondary" type="button" id="showPasswordButton">
    <i class="fa fa-regular fa-eye" id="eyeIcon">
    </i>
    </button>
    </div>
    </div>
    </div>
    <div class="form-group text-center mt-2">
    <cfinput type="submit" name="submit" class="btn btn-primary" value="Sign in">
    </div>
</cfform>
</div>
<!---Form Ends Here --->
<!--- Processing --->
<cfif structkeyExists(form, 'submit')>
    <cfset aErrorMessages = authenticationService.validateUser(form.email, form.password)/>
    <cfif ArrayisEmpty(aErrorMessages)>
        <cfset isUserLoggedIn = authenticationService.doLogin(form.email, form.password)/>
    
        <cfset message = "User logged in with Email: #form.email# and Password: #form.password# at #currentDate# , #currentTime#">
        <cflog type="any" file="logs" text="#message#">
    </cfif>
</cfif>

<cfif structkeyexists(variables, 'aErrorMessages') and not ArrayIsEmpty(aErrorMessages)>
    <cfoutput>
        <cfloop array="#aErrorMessages#" item="message">
            <p>
            #message#
            </p>
        </cfloop>
    </cfoutput>
</cfif>
<cfif structkeyexists(variables, 'isUserLoggedIn') and isUserLoggedIn eq false>

    <cflocation url="/finalAssignment/auth/login.cfm?x=#codeWords.invalidUser#">
</cfif>
<cfif structkeyexists(session, 'userDetail') and structkeyexists(variables, 'isUserLoggedIn') and isUserLoggedIn 
      eq true>
    <script>
    let result = confirm("Log-in Successfull, Go to Dashboard!");
    if (result) {
    window.location.href = "/finalAssignment/index.cfm";
    }
    else{
    window.location.href = "login.cfm?x=
    <cfoutput>#codeWords.cancel#</cfoutput>
    ";
    }
    </script>
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
</body>
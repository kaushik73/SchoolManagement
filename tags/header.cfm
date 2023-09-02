<!DOCTYPE html>
<html>
<head>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" 
      crossorigin="anonymous">
</head>
<body>
<cfparam name="attributes.pageTitle" default="No Title">
<cfif thisTag.executionMode eq 'start'>
    <div class='text-center'>
    <h2>
    <cfoutput>#attributes.pageTitle#</cfoutput>
    </h2>
    </div>
<cfelse>
    <hr>
</cfif>
</body>
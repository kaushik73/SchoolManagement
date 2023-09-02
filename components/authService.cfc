<cfcomponent output="false">
    <!---Validate User Method --->
    <cffunction name="validateUser" access="public" output="false" returntype="array">
    <cfargument name="userEmail" type="string" required="true" >
    <cfargument name="userPassword" type="string" required="true" >
        <cfset aErrorMessage = ArrayNew(1)>
        <cfif NOT isValid('email' , arguments.userEmail)>
            <cfset arrayAppend(aErrorMessage , 'Provide Valid Email')>
        </cfif>
        <cfif arguments.userPassword eq ''>
            <cfset arrayAppend(aErrorMessage , 'Provide Valid Password')>
        </cfif>
        <cfreturn aErrorMessage>
    </cffunction>
    
    <!---Log IN Method --->    
    <cffunction name="doLogin" access="public" output="false" returntype="boolean">
    <cfargument name="userEmail" type="string" required="true">
    <cfargument name="userPassword" type="string" required="true">

    <cfset var isUserLogin = false>
    <cfquery name="authData" datasource="ColdFusion">
        SELECT R.Type as Type, A.UserId as UserId, A.Email as Email, A.Password as Password
        FROM Auth A
        JOIN Role R ON A.RoleId = R.RoleId
        WHERE A.Email = <cfqueryparam value="#arguments.userEmail#" cfsqltype="CF_SQL_VARCHAR">
        AND A.Password = <cfqueryparam value="#arguments.userPassword#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
    
    <cfif authData.recordCount eq 1>
        <cfset session.userDetail = {
            'userId': authData.UserId,
            'userName': '',
            'phoneNumber': '',
            'guardianEmail' : '',
            'role' : ''
        }>
        
        <cfif authData.Type eq 'student'>
            <cfquery name="userData">
                SELECT *
                FROM StudentDetail
                WHERE StudentID = <cfqueryparam value="#authData.UserId#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfif userData.recordCount eq 1>
                <cfset session.userDetail['userName'] = userData.StudentName>
                <cfset session.userDetail['phoneNumber'] = userData.StudentPhoneNumber>
                <cfset session.userDetail['guardianEmail'] = userData.GuardianEmail>
				<cfset session.userDetail['role'] = 'student'> 
            </cfif>
        <cfelseif authData.Type eq 'teacher'>
            <cfquery name="userData">
                SELECT *
                FROM TeacherDetail
                WHERE TeacherID = <cfqueryparam value="#authData.UserId#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfif userData.recordCount eq 1>
                <cfset session.userDetail['userName'] = userData.TeacherName>
                <cfset session.userDetail['phoneNumber'] = userData.PhoneNumber>
                <cfset session.userDetail['role'] = 'teacher'>

            </cfif>
        <cfelse>
            <cfquery name="userData">
                SELECT *
                FROM AdminDetail
                WHERE AdminID = <cfqueryparam value="#authData.UserId#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfif userData.recordCount eq 1>
                <cfset session.userDetail['userName'] = userData.adminName>
                <cfset session.userDetail['phoneNumber'] = userData.PhoneNumber>
                <cfset session.userDetail['role'] = 'admin'>
            </cfif>
        </cfif>     
        <cfset isUserLogin = true>
    </cfif>
    
    <cfreturn isUserLogin>
</cffunction>

    <!---Log OUT Method --->
    <cffunction name="doLogout" access="public" output="false" returntype="void">
            <cfset structDelete(session , 'userDetail')>
    </cffunction>
    </cfcomponent>
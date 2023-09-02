<cfcomponent output="false">

	<cffunction name="sendEmail" access="public" output="false" returntype="string">
		<cfargument name="toEmail" type="array" required="true"/>
		<cfargument name="fromEmail" type="email" required="true"/>
		<cfargument name="emailSubject" type="string" required="true"/>
		<cfargument name="emailContent" type="string" required="true"/>
		<cfargument name="sendToAdmins" type="boolean" required="true"/>
		<cftry>
			<cfquery name="GetAdminsDetail">
				Select Email from AdminDetail;
			</cfquery>
			<cfset isValidEmailList = true>
			<cfloop array="#arguments.toEmail#" index="email">
				<cfif NOT isValid("email", email)>
					<cfset isValidEmailList = false>
					<cfbreak>
				</cfif>
			</cfloop>
			<cfif isValidEmailList>
				<cfloop array="#arguments.toEmail#" index="email">
					<cfmail to="#email#" from="#arguments.fromEmail#" subject="#arguments.emailSubject#">
						#arguments.emailContent#
					</cfmail>
				</cfloop>
				<cfif arguments.sendToAdmins>
				
					<cfloop query="GetAdminsDetail">
						<cfmail to="#GetAdminsDetail.email#" from="#arguments.fromEmail#" 
						        subject="#arguments.emailSubject#">
							#arguments.emailContent#
						</cfmail>
					</cfloop>
				</cfif>
			<cfelse>
				<p class="alert alert-danger">
					All Email are not valid, Please Try Sending Again!
				</p>
				<cfreturn 'All Email are not valid, Please Try Sending Again!'>
			</cfif>
			<cfif isValidEmailList>
				<p class="alert alert-success">
					Mail Sent SuccessFully!
				</p>
				<cfreturn 'Mail Sent SuccessFully!'>
			</cfif>
		<cfcatch type="any">
			<p class="alert alert-danger">
				An Error Occuced, please Try Again!
			</p>
			<cfreturn 'An Error Occuced, please Try Again!'>
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getCodeWords" access="public" output="false" returntype="struct">
		<cfset var Codewords = StructNew ( )>
		<cfset Codewords.logout = '10oyt1'>
		<cfset Codewords.cancel = '20oqn2'>
		<cfset Codewords.reload = '30otu3'>
		<cfset Codewords.updated = '40orw4'>
		<cfset Codewords.noChange = '50ofd5'>
		<cfset Codewords.courseModified = '60ozs6'>
		<cfset Codewords.invalidUser = '70ozs7'>
		<cfset Codewords.courseLimitExceed = '80ozs8'>
		<cfreturn Codewords>
	</cffunction>
	
</cfcomponent>
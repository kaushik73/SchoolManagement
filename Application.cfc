<cfcomponent>
    <cfset this.name = "School App">
    <cfset this.datasource = 'finalAssignment'>
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimespan(0, 0, 20, 0)><!---20 min. session --->
    <cfset this.customTagPaths = expandPath('/finalAssignment/tags')>
</cfcomponent>
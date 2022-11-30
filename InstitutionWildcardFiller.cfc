<cfcomponent extends="AbstractInstitutionWildcardFiller">

    <cffunction name="replaceAdmissionWildcards" access="public" returntype="string">
        <cfargument name="content" type="string" required="true">
        <cfargument name="idnumber" type="numeric" required="true">
        <cfargument name="appNumber" type="numeric" required="true">
        <cfscript>
            var contentValue = content;
            var errorLog = CreateObject("istart.core.ErrorLogger");
        </cfscript>

        <!---
        Advanced Admissions Logic:
            Looks for conditional text in the format of
            [adm_dbcolumn_value]content[/adm_dbcolumn_value].
            Example:
            [adm^ACAD_CAREER_CD^UGRD]Insert this text[/adm^ACAD_CAREER_CD^UGRD]

            The following code searches for all text that matches that format.
            When that text is found, the column is compared to a column in iuieadmissions.  If the column is valid, the code will compare the expected value to what is in the database.  If they match, then the content between the open/close brackets will be displayed.  Otherwise, the whole text that is found will be erased from the output.  If the column does not exist in the database, an error will be logged in IOfficeLog and the found text will be erased from the output.

        --->
        <cfquery name="admissionsLogicQuery" maxrows="1">
            SELECT TOP 1 *
            FROM iuieadmissions
            WHERE idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#">
                AND appl_nbr = <cfqueryparam cfsqltype="cf_sql_integer" value="#appNumber#">
        </cfquery>

        <cfscript>
            regex = "\[adm\^{1}(\w*)\^{1}(\S*)\]((?>.|\s)*?)\[\/adm\^\1\^\2\]";

            objPattern = CreateObject("java","java.util.regex.Pattern").Compile(regex);

            objMatcher = objPattern.Matcher(JavaCast( "string", contentValue));

            while(objMatcher.Find())
            {
                //first group contains the column to be retrieved from the database
                //second group contains the value to compare against the database value
                //third group contains the information that should be visible if their is a match on the values.
                dbColumn = objMatcher.group(1);
                compareData = objMatcher.group(2);
                contentToInsert = objMatcher.group(3);

                if(StructKeyExists(admissionsLogicQuery,dbColumn))
                {
                    dbValue = StructFind(admissionsLogicQuery,dbColumn);

                    compareList = ListToArray(compareData,',',false,false);

                    if ( arrayContains(compareList,dbValue))
                    {
                        contentValue = objMatcher.replaceFirst(contentToInsert);
                    }
                    else
                    {
                        contentValue = objMatcher.replaceFirst("");
                    }
                }
                else
                {
                    contentValue = objMatcher.replaceFirst("");

                    errorLog.logError("LogicError","InstitutionWildcardFiller.cfc","Admissions Conditional Logic", "CustomWildCards","Logic in communication references a column in DB that doesn't exist: "&dbColumn);
                }

                //reset matcher to start a new find
                objMatcher = objPattern.Matcher(JavaCast( "string", contentValue));
            }
        </cfscript>


        <cfreturn contentValue>
    </cffunction>

</cfcomponent>
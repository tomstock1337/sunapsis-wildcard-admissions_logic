# InstitutionWildcardFiller.cfc

## Admissions Conditional Logic
This segment of code is used to impose conditional logic based on values in iuieadmissions. If the value is found, the content between the conditional tags will be displayed. Otherwise, all of the conditional expression is erased. The general layout for this extension is:

Regex `\[adm\^{1}(\w*)\^{1}(\S*)\]((?>.|\s)*?)\[\/adm\^\1\^\2\`

Pseudo-Usage
`[adm^dbColumn^commListDBValues]contentToInsert[/adm^dbColumn^commListDBValues]`

-	dbColumn is any column on iuieadmissions.
-	commListDBValues is a comma delimited list of code values as depicted in iuieadmissions.
-	contentToInsert is the content that should be displayed if the value in the database is equal to an item in the commListDBValues parameter.

**Example:**
Looks for value of CO in acad_grp_cd for the checklists' idnumber and app number.

```
Welcome to the university. [adm^acad_grp_cd^CO] You must participate in the English Language Program.[/adm^acad_grp_cd^CO]
```

**Example:**
Looks for value of either CERG-BUS or CERG-BUS-NET in acad_pgm_cd for the checklists' idnumber and app number.
```
Welcome to the university. [adm^acad_pgm_cd^CERG-BUS,CERG-BUS-NET] You are part of our business certificate program[/adm^acad_pgm_cd^CERG-BUS,CERG-BUS-NET]
```
## Errors
If the dbColumn is not valid, an error will be logged into IOfficeLog. The text of the expression would be erased.

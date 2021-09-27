# OSG
# ⌨ >= ⚔
# Juvenal.ps1
# Powershell V 7/5/2
# This module simplifies searching text files

#                ;~~,__
# :-....,-------'`-'._.'
# `-,,,  ,       ,'~~'
#     ; ,'~.__; /--.
#     :| :|   :|``(;
#     `-'`-'  `-'

function birddog {
    [CmdletBinding()]
    param (

        # filepath parameter
        [Alias("p")]
        [Parameter(
        HelpMessage="Enter a relative or absolute path to files.")]
        [string]$Path,

        # searchterm parameter
        [Alias("s")]
        [Parameter(
        HelpMessage="Enter the string you are searching for. (Regex compatible)")]
        [string]$Searchterm,

        # print help message switch
        [Alias("h")]
        [Parameter(HelpMessage="Use `"-h`" to display the help message")]
        [switch]$Help,

        # Recursive search switch 
        [Parameter(HelpMessage="Recurse searches all sub directories / files within the path specified in the -path parameter.
        Does not support .xlsx files")]
        [switch]$Recurse,

        # Case sensitive switch
        [Alias("c")]
        [Parameter(HelpMessage="Indicates that the search is case-sensitive. By default, searches are not case-sensitive.")]
        [switch]$CaseSensitive,

        # Regex string parameter
        [Parameter(HelpMessage="Regular Expressions valid options include: 'credit card', 'date', 'email', 'IPv4', 'IPv6', 'MAC', 'password', 'phone', 'port', 'SSN', 'time', 'URL'")]
        [ValidateSet("credit card", "date", "email", "IPv4", "IPv6","MAC", "password", "phone", "port", "SSN", "time", "URL")]
        [string]$Regex,

        #Find and replace parameter
        [Parameter(HelpMessage="Term to replace searchterm. does not support .xlsx files.")]
        [string]$Replace
    )

    $helptext ="`nNAME
    Birddog

SYNOPSIS
    Birddog is a PowerShell function for parsing pure text and .xlsx files for a search term and identifying the lines where that term occurs. 

    
DESCRIPTION

PARAMETERS

-Path <System.String[]>
    Specifies a path to one or more locations. Wildcards are accepted. `".`" Specifies the current directory.
    
-Searchterm <System.String[]>
    Specifies the text to find on each line. The pattern value is treated as a regular expression.
    To learn about regular expressions, see about_Regular_Expressions
    (../Microsoft.PowerShell.Core/About/about_Regular_Expressions.md)

-Help
    Displays this help message.

-Recurse <System.Management.Automation.SwitchParameter>
    Gets the items in the specified locations and in all child items of the locations.

-CaseSensitive <System.Management.Automation.SwitchParameter>
    Indicates that the cmdlet matches are case-sensitive. By default, matches aren't case-sensitive.

-Regex
    Birddog has built in Regular Expressions to match a variety of patterns.
    These include:
    'credit card', 'date', 'email', 'IPv4', 'IPv6', 'MAC', 'password', 'phone', 'port', 'SSN', 'time', 'URL'.
    If you want your own Regex, use the -Searchterm switch.

-Replace <System.String[]>
    Specifies a string to replace the searchterm.


SYNTAX
    birddog -<Path> <System.String[]> [-<searchterm>] <string> [-<Help>] [-<Recurse>] [-<CaseSensitive>] -<Regex> <`"credit card`"> | <date> | <email> | <IPv4> | <IPv6> | <MAC> |  <password>  | <phone> | <port> | <SSN> | <time> | <URL>

EXAMPLES
    -------- Example 1: search file.txt for the string `"cookies`" --------
    birddog -path file.txt -searchterm cookies

    -------- Example 2: search the C: drive recursively for the string `"cookies and cream`" --------
    birddog -recurse -path C:\ -searchterm `"cookies and cream`"

    -------- Example 3: search file.txt in another directory for the string `"cookies`" with case sensitivity --------
    birddog -Path C:\path\to\file.txt -Searchterm cookies -CaseSensitive

    -------- Example 3.5: Preform the same search as example 3 using parameter aliases --------
    birddog -p path\to\file.txt -s cookies -c

    -------- Example 4: search a file using a regular expression for IPv4 addresses --------
    birddog -path C:\absolute\path\to\file -Regex IPv4


REMARKS
    The `"-Recurse`" switch must be invoked if replacing terms specified by the `"-Regex`" parameter in more than one file.

RELATED LINKS:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_command_syntax?view=powershell-7.1
    
    " 

    $format = "`nfile:linenumber:line contents"
    $Pipe1 = "Get-ChildItem -ErrorAction Stop $path"
    $Pipe2 = " | Select-String -AllMatches -Pattern $Searchterm"
    $Editedfiles = $null

    # if -help
    if ($help){
        Write-Host $helptext | Format-Table -AutoSize 
    }
    #if help in not invoked and (path or searchterm) are missing
    elseif ( !($help) -and ( !($PSBoundParameters.ContainsKey('path') -or !($PSBoundParameters.ContainsKey('searchterm') ) ) ) ) {
        Write-Host "`n-path and -searchterm parameters must be supplied"
        Write-Host "Use `"birddog -h`" for help`n"
    }
    # if casesensitive and regex are invoked together
    elseif ($CaseSensitive -and $Regex) {
        Write-host "Sorry, `"-CaseSensitive`" and `"-Regex`" can not be invoked together"
        Write-host $helptext | Format-Table -AutoSize
    }

    # else the function was called with suficient parameters
    else {
        $extn = [IO.Path]::GetExtension($path)

        try{
            # if xlsx file
            if ($extn -eq ".xlsx") {
                #check for importexcel module, if it's not installed it will be (to facilitate .xlsx interactivity)
                if (-not (Get-Module -Name importexecel)) {
                    Install-Module importexcel -Scope CurrentUser
                }
                $search = Import-Excel -Path $path -noheader | Select-String -AllMatches -Pattern $searchterm
                $output =[ordered]@{
                    'SearchTerm' = $null
                    'Row' = $null
                }
                $output.SearchTerm = $searchterm
                $output.Row = $Search.LineNumber
                [pscustomobject]$output
            
            # else all other text encoded files
            } else {
                #Append Pipe string vars that will be cated and invoked later
                if ($Recurse){
                    $Pipe1 = $Pipe1 + " -Recurse"
                }
                #if casesensitive not recursive
                if($CaseSensitive){
                    $Pipe2 = $Pipe2 + " -CaseSensitive"
                }

                #This has to be the last append to $Pipe2
                if($Regex){
                    #Substitute regex for searchterm

                    #Supports group 1-6 cards
                    if($Regex -like "credit card"){
                        $Searchterm ='(^4[0-9]{12}(?:[0-9]{3})?$)|(^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$)|(3[47][0-9]{13})|(^3(?:0[0-5]|[68][0-9])[0-9]{11}$)|(^6(?:011|5[0-9]{2})[0-9]{12}$)|(^(?:2131|1800|35\d{3})\d{11}$)'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    #Supports calendar date formats: YYYY-MM-DD (ISO 8601), DD/MM/YYYY , DD-MM-YYYY , DD.MM.YYYY
                    elseif($Regex -like "date"){
                        $Searchterm ='^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})|^\d{4}-(02-(0[1-9]|[12][0-9])|(0[469]|11)-(0[1-9]|[12][0-9]|30)|(0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))$|\b^\d{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports email
                    elseif($Regex -like "email"){
                        $Searchterm = '[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports IPv4 addresses
                    elseif ($Regex -like "IPv4") {
                        $Searchterm = '(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports IPv6 addresses
                    elseif ($Regex -like "IPv6") {
                        $Searchterm = '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports Media Access Control addresses
                    elseif ($Regex -like "MAC"){
                        $Searchterm = '^[a-fA-F0-9]{2}(:[a-fA-F0-9]{2}){5}$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports passwords that are minimum eight characters, at least one upper case English letter, one lower case English letter, one number and one special character. Or the litteral string "password"
                    elseif($Regex -like "password"){
                        $Searchterm = '^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$ %^&*-]).{8,}$|\W*((?i)password(?-i))\W*'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports Phone numbers in the following formats: +xxxxxxxxxxx , +xxxxxxxxxxxxx , xxxxxxxxxx , xxx-xxx-xxxx
                    elseif ($Regex -like "phone") {
                        $Searchterm = '^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports IP ports 0-65535
                    elseif ($Regex -like "port") {
                        $Searchterm = '^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports Social Security Numbers xxx-xx-xxxx
                    elseif ($Regex -like "SSN"){
                        $Searchterm = '^(?!0{3})(?!6{3})[0-8]\d{2}-(?!0{2})\d{2}-(?!0{4})\d{4}$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    # Supports 12/24 hour time formats: xx:xx am/pm (case insensitive), x:xx am/pm (case insensitive), xx:xx (24hr)
                    elseif ($Regex -like "time") {
                        $Searchterm = '\b(?:(?:0){0,1}[1-9]|[1-1][0-2]):(?:(?:0){1}[0-9]|[1-4][0-9]|[5-5][0-9])\s*(?:AM|am|PM|pm)\b|\b([01]?[0-9]|2[0-3]):[0-5][0-9]$'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    elseif ($Regex -like "URL") {
                        $Searchterm = 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_\+.~#?&\/\/=]*)'
                        if(!($Replace)){
                            $Searchterm = ($Searchterm | ForEach-Object{"'" + "$_`'"})
                            $Pipe2 += $Searchterm
                        }
                    }
                    else{
                        Write-Host "Invalid input.`n Accepped inputs are:`n credit card`n date`n email`n IPv4`n IPv6`n MAC`n password`n phone`n port`n SSN`n time`n URL"
                        Write-Host "The `"-Searchterm`" parameter accepts your custom regex"
                    }
                }
                # replace no recursion
                if($Replace -and !($Recurse)){
                    $Pipe1 = "(Get-Content -path $path) -replace '$Searchterm','$Replace'"
                    $Pipe2 = " | Set-Content -path $path"
                }
                # Recursively find and replace
                if(($Replace) -and ($Recurse) -and ($Searchterm)){
                    $EditedFiles = Get-ChildItem -path $Path -Recurse
                    foreach ($file in $EditedFiles){
                        # if regex recursive replacement
                        if($Regex){
                            Write-Host $file
                            $Pipe1 = "(Get-Content -path $file) -replace '$Searchterm','$Replace'"
                            $Pipe2 = " | Set-Content -path $file"
                            $Search = $Pipe1 + $Pipe2
                            $Search | Invoke-Expression
                            if(Get-Content -Path $file | Select-String -AllMatches -Pattern `'$Searchterm`'){
                                Write-Host "Replacing `"$Regex`" in `"$file`""
                            }
                        }   #Non-regex recursive replacement
                            else{
                            $content = [System.IO.File]::ReadAllText($file.FullName).Replace("$Searchterm","$Replace")
                            [System.IO.File]::WriteAllText($file.FullName, $content)
                            }
                    }
                    Write-Host "Sucessfully replaced $Searchterm with `"$Replace`" in $path"
                }
                # If no recursive find with searchterm and replace 
                elseif(($Replace) -and (!($Recurse)) -and ($Searchterm) ){
                    $Search = $Pipe1 + $Pipe2
                    $Search | Invoke-Expression
                    # If LineNumber not null (results found)
                    if($Search | Invoke-Expression | Select-Object LineNumber){
                        Write-Host $format
                    }
                    # else replaced searchterm in single file
                    elseif( $Replace -and (Get-Content -path $Path | Select-String $Replace) -and (!(Get-Content -path $Path | Select-String $Searchterm ))){
                        Write-Host "Successfully replaced `"$Searchterm`" with `"$Replace`" in $path"
                    }
                    else{
                        Write-Host "`nNo Results Found loser`n"
                    }
                }
                # Execute plain regex search
                if($Regex -and ($Path)){
                    $Search = $Pipe1 + $Pipe2
                    $Search | Invoke-Expression
                }
                else{
                    $Search = $Pipe1 + $Pipe2
                    $Search | Invoke-Expression
                }
            }
        }
        # catch no parameter execution
        catch [System.Management.Automation.ParameterBindingException] {
            Write-Host $helptext | Format-Table -AutoSize
        }
        #catch invalid path parameter
        catch [System.Management.Automation.ItemNotFoundException]{
            Write-Host "`nFile not found."
            Write-host "Check path parameter and try again"
        }
    }
}

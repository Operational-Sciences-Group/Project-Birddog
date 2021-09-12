#implement the birddog function
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
        [switch]$Recurse
    )
    $helptext ="`nNAME
    birddog

SYNOPSIS
    birddog is a PowerShell function for parsing a pure text and .xlsx files for a search term and identifying the lines where that term occurs. 
    The intended use-case is for identifying the location of a string for manual manipulation where automatically replacing every occurrence 
    of the string within the file with PowerShell is unwanted.
        
SYNTAX
    birddog -path <relative\or\absolute\path\to\file.txt> -searchterm <yoursearchterm> -recurse

    birddog -p <relative\or\absolute\path\to\file.txt> -s <yoursearchterm> -recurse

    # if -help
    if ($help){
        Write-Host $helptext | Format-Table -AutoSize 
    }
    #if help in not invoked and (path or searchterm) are missing
    elseif ( !($help) -and ( !($PSBoundParameters.ContainsKey('path') -or !($PSBoundParameters.ContainsKey('searchterm') ) ) ) ) {
        Write-Host "`n-path and -searchterm parameters must be supplied"
        Write-Host "Use `"birddog -h`" for help`n"
    }

    # else the function was called with suficient parameters
    else {
        $extn = [IO.Path]::GetExtension($path)

        try{
            # if xlsx file
            if ($extn -eq ".xlsx") {
                #check for importexcel module, if it's not installed it will be (to facilitate .xlsx interactivity)
                if (-not (Get-Module -Name importexecel)) {
                    install-module importexcel -scope CurrentUser
                }
                $search = Import-Excel -Path $path -noheader | Select-String -Pattern $searchterm
                $output =[ordered]@{
                    'SearchTerm' = $null
                    'Row' = $null
                }
                $output.SearchTerm = $searchterm
                $output.Row = $search.LineNumber
                [pscustomobject]$output

            # else all other text encoded files
            } else {
                #Recursive search
                if ($Recurse){
                    Write-Host "`nfile:linenumber:line contents`n"
                    Get-ChildItem -Recurse -Path $path -ErrorAction Stop | Select-String -Pattern $searchterm
                }
                # No recursion
                else {
                    $search = Get-ChildItem -Path $path -ErrorAction Stop | Select-String -Pattern $searchterm
                    $output =[ordered]@{
                    'SearchTerm' = $null
                    'LineNumber' = $null
                }
                $output.SearchTerm = $searchterm
                $output.LineNumber = $search.LineNumber
                if(!($search.LineNumber)){
                    Write-Host "`nNo results found"
                }
                [pscustomobject]$output
                Write-Host $output | Format-Table -AutoSize
                }
            }
        }
        # catch no parameter execution
        catch [System.Management.Automation.ParameterBindingException] {
            Write-Host $helptext | Format-Table -AutoSize
        }
        # catch invalid path parameter
        catch [System.Management.Automation.ItemNotFoundException]{
            Write-Host "`nFile not found."
            Write-host "Check path parameter and try again"
        }
    }
}

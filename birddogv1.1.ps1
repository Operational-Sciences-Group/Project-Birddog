#implement the birddog function
function birddog {
    [CmdletBinding()]
    param (
        [Alias("p")]
        [Parameter(
        HelpMessage="Enter a relative or absolute path to files.")]
        [string]$path,

        [Alias("s")]
        [Parameter(
        HelpMessage="Enter the string you are searching for. (Regex compatible)")]
        [string]$searchterm,

        [Alias("h")]
        [Parameter(HelpMessage="Use `"-h`" to display the help message")]
        [switch]$help
    )
    $helptext ="`nNAME
    birddog

SYNOPSIS
    birddog is a PowerShell function for parsing a pure text and .xlsx files for a search term and identifying the lines where that term occurs. 
    The intended use-case is for identifying the location of a string for manual manipulation where automatically replacing every occurrence 
    of the string within the file with PowerShell is unwanted.
        
SYNTAX
    birddog -path <relative\or\absolute\path\to\file.txt> -searchterm <yoursearchterm>

    birddog -p <relative\or\absolute\path\to\file.txt> -s <yoursearchterm>

REMARKS
    Please note: birddog checks for the installation of the 'importexcel' module to facilitate .xlsx functionality when a .xlsx file is provided. 
    If the importexcel module is not installed, it will attempt to install the module. This will fail in a standard PowerShell session, 
    as PowerShell module installations require the PowerShell session to be run as administrator. 
    This check and/or install will not occur when non-.xlsx files are provided.`n"

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
                    install-module importexcel
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
                $search = Get-Content -Path $path -ErrorAction Stop | Select-String -Pattern $searchterm
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
        # Catch insufficient permissions
        catch [System.UnauthorizedAccessException]{
            Write-Host "`n The importexcel module is not installed and the current process has insufficient permissions to install it."
            Write-Host "Try running this command again with administrator privileges`n"
        }
        catch [System.Security.SecurityException]{
            Write-Host "`n The importexcel module is not installed and the current process has insufficient permissions to install it."
            Write-Host "Try running this command again with administrator privileges`n"
        }
    }
}

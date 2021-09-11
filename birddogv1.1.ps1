#Implement the birddog function:
function birddog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$filepath,

        [Parameter(Mandatory=$true)]
        [string]$searchterm,

        [Parameter(Mandatory=$false)]
        [switch]$nocsvheader
    )
    $extn = [IO.Path]::GetExtension($filepath)
    if (($nocsvheader -eq $true) -or ($extn -eq ".json")) {
        $search = Get-Content -Path $filepath | Select-String -Pattern $searchterm
        $output =[ordered]@{
            'SearchTerm' = $null
            'LineNumber' = $null
        }
        $output.SearchTerm = $searchterm
        $output.LineNumber = $search.LineNumber
        [pscustomobject]$output
    } elseif ($extn -eq ".csv" ) {
        $search = Import-Csv -Path $filepath | Select-String -Pattern $searchterm
        $output =[ordered]@{
            'SearchTerm' = $null
            'LineNumber' = $null
        }
        $output.SearchTerm = $searchterm
        $output.LineNumber = $search.LineNumber
        [pscustomobject]$output
    } elseif ($extn -eq ".xlsx") {
        if (-not (Get-Module -Name importexcel)) {
            install-module importexcel
        }
        $search = Import-Excel -Path $filepath -noheader | Select-String -Pattern $searchterm
        $output =[ordered]@{
            'SearchTerm' = $null
            'Row' = $null
        }
        $output.SearchTerm = $searchterm
        $output.Row = $search.LineNumber
        [pscustomobject]$output
    } else {
        Write-Error "The file $filepath is an unsupported format."
    }
}
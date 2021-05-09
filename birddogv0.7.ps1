function birddog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$filepath,

        [Parameter(Mandatory)]
        [string]$searchterm
    )
    $extn = [IO.Path]::GetExtension($filepath)
    if ($extn -eq ".csv" ) {
        $search = Import-Csv -Path $filepath | Select-String -Pattern $searchterm
        $output = @{
            'SearchTerm' = $null
            'LineNumber' = $null
        }
        $output.SearchTerm = $searchterm
        $output.LineNumber = $search.LineNumber
        [pscustomobject]$output
    } elseif ($extn -eq ".json" ) {
        $search = Get-Content -Path $filepath | Select-String -Pattern $searchterm
        $output = @{
            'SearchTerm' = $null
            'LineNumber' = $null
        }
        $output.SearchTerm = $searchterm
        $output.LineNumber = $search.LineNumber
        [pscustomobject]$output
    } else {
        Write-Error "The file $filepath is an unsupported format."
    }
}
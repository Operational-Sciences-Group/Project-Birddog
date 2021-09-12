'birddog' (at current version 1.2) is a PowerShell function for parsing structured text (.csv, .json, .txt etc.) and .xlsx files for a search term and 
identifying the lines where that term occurs.  The intended use-case is for identifying the location of a string for manual
manipulation where automatically replacing every occurrence of the string within the file with PowerShell is 
unwanted.\
\
Please note: birddog checks for the installation of the 'importexcel' module to facilitate .xlsx functionality when a .xlsx file is provided.  If the importexcel module is not installed, it will attempt to install the module.  This will fail in a standard PowerShell session, as PowerShell module installations require the PowerShell session to be run as administrator.  This check and/or install will not occur when structured text files are provided.\
\
Once 'birddogv1.2.ps1' is run within a PowerShell session, the function can be invoked in one of two ways;  By
feeding the 'path' and 'searchterm' parameters on the same line:\
\
``` PS C:\> birddog -path C:\example.csv -searchterm ThingImLookingFor ``` \
\
Or via invoking the function, and giving the 'path' and 'searchterm' parameters as prompted:\
\
``` PS C:\> birddog ``` \
``` cmdlet birddog at command pipeline position 1 ``` \
``` Supply values for the following parameters: ``` \
``` path: C:\example.csv ``` \
``` searchterm: ThingImLookingFor ``` \
\
Note: Birddog can also be piped into Format-Table to clean up results if necessary:\
\
``` PS C:\> birddog -filepath C:\example.csv -searchterm ThingImLookingFor | Format-Table -Autosize ``` \
\
With version 1.2, parameter aliases ``` -p ``` and ``` -s ``` can be used in place of ``` -path ``` and ``` -searchterm ``` respectivley.  A help page can be viewed on the command line with:\
``` birddog -help ``` or ``` birddog -h ```\
As of version 1.2 structured text and .xlsx files are supported.  .xlsx files will display the searchterm location as 'Row' (reflecting the typical spreadsheet term) instead of 'LineNumber' used in all other structured text results.\
Thank you for reading!

'birddog' (at current version 1.1) is a PowerShell function for parsing a .csv, .json, or .xlsx file for a search term and 
identifying the lines where that term occurs.  The intended use-case is for identifying the location of a string for manual
manipulation where automatically replacing every occurrence of the string within the file with PowerShell is 
unwanted.\
\
Please note: birddogv1.ps1 checks for the installation of the 'importexcel' module to facilitate .xlsx functionality when a .xlsx file is provided.  If the importexcel module is not installed, it will attempt to install the module.  This will fail in a standard PowerShell session, as PowerShell module installations require the PowerShell session to be run as administrator.  This check and/or install will not occur when .csv or .json files are provided.\
\
Once 'birddogv1.1.ps1' is run within a PowerShell session, the function can be invoked in one of two ways;  By
feeding the 'filepath' and 'searchterm' parameters on the same line:\
\
``` PS C:\> birddog -filepath C:\example.csv -searchterm ThingImLookingFor ``` \
\
Or via invoking the function, and giving the 'filepath' and 'searchterm' parameters as prompted:\
\
``` PS C:\> birddog ``` \
``` cmdlet birddog at command pipeline position 1 ``` \
``` Supply values for the following parameters: ``` \
``` filepath: C:\example.csv ``` \
``` searchterm: ThingImLookingFor ``` \
\
As of version 1.1, Birddog can be instructed to ignore csv headers (and include the header line in the 'Line Number' count) with the ```-nocsvheader``` switch.\
Note: Birddog can also be piped into Format-Table to clean up results if necessary:\
\
``` PS C:\> birddog -filepath C:\example.csv -searchterm ThingImLookingFor | Format-Table -Autosize ``` \
\
As of version 1.1 .csv, .json, and .xlsx files are supported.  .xlsx files will display the searchterm location as 'row' (reflecting the typical spreadsheet term) instead of 'Line Number' used in .csv and .json results.\
Thank you for reading!

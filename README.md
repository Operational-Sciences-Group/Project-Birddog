# Project-Birddog
#### Powershell module search function
![GitHub top language](https://img.shields.io/github/languages/top/Operational-Sciences-Group/Project-birddog?label=PowerShell&logo=powershell&style=plastic)
![Version](https://img.shields.io/badge/Version-1.4-sucess?style=plastic)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Operational-Sciences-Group/Project-Birddog?style=plastic)
![GitHub issues](https://img.shields.io/github/issues/Operational-Sciences-Group/Project-Birddog?style=plastic)

Birddog is a PowerShell (Version 7/5/2) module for searching raw text and .xlsx files for a search term and identifying the lines where that term occurs. It also has the ability to find and replace. 

## Table of contents

1. [About](https://github.com/JoustingZebra/Project-Birddog/blob/main/README.md#about)
2. [Installation / Usage](https://github.com/JoustingZebra/Project-Birddog/blob/main/README.md#installation--usage)
3. [Credits]()
4. [Disclaimer / Warning]()
5. [License]()

## About

Have you even wanted to search a text file for Social Security Numbers, passwords, or anything else with PowerShell?

Do you occasionally struggle with regex?

If so, Birddog is for you!


Birddog simplifies your PowerShell searches of text files. Let's look at an example:

If you want to search a file for a IPv4 address and censor it with the string "Removed for privacy", you basically have to tangle with a monster like this:

```(Get-Content -Path <path>) -Replace '(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}','Removed for privacy' | Set-Content -Path <path> ```

Birddog gets identical results with the easier command:

```Birddog -Path <path> -Regex IPv4 -Replace "Removed for privacy"```

## Installation / Usage

Install using PowerShell Version 3 or later:

 1. Find the PSModule paths:

```$Installpath = $env:PSModulePath -split ";"```

2. Change directory into the first entry of $env:PSModulePath:

```Set-Location $Installpath[0]```

 3. Create new self-named folder for the module:

``` New-Item -Path 'Birddog' -ItemType Directory ```

4. Change directory into that folder:

``` Set-Location .\Birddog\ ```

 5. Put Birddog.psm1 inside a self-named folder on $env:PSModlePath:

``` (Invoke-WebRequest -URI "https://raw.githubusercontent.com/JoustingZebra/Project-Birddog/main/birddogV1.4.ps1").Content > Birddog.psm1 ```

6. Change Execution policy for the scope of the current PowerShell process:

``` Set-ExecutionPolicy Bypass -Scope Process```

 7. Import the module into the current session:

``` Import-Module Birddog ```

### Usage

Example 0 (print help message):

``` Birddog -Help```

Example 1 (simple search) :

```Birddog -Path <path> -SeachTerm <searchterm>```

Example 2 (seach and replace) :

```Birddog -Path <path> -Searchterm <searchterm> -Replace <"string to replace searchterm">```

Example 3 (recursive search and and replace on the current directory):

```Birddog -Path . -Recurse -Searchterm <searchterm> -Replace <"string to replace searchterm">1```

Example 4 (seach for Ipv4 addresses in file):

``` Birddog -Path <path> -Regex IPv4```


**Parameters**
| Switch  | Alias |
| ------------- | ------------- |
| -Path  | -p  |
| -SearchTerm  | -s |
| -CaseSensitive  | -c |
| -Help  | -h |
| -Recurse  | N/A |
| -Regex | N/A |
| -Replace | N/A |


**List of Valid -Regex options:**

- 'credit card' (Supports group 1-6 cards)
- date  (Supports calendar date formats: YYYY-MM-DD (ISO 8601), DD/MM/YYYY , DD-MM-YYYY , DD.MM.YYYY)
- email 
- IPv4  (Supports Internet Protocol version 4 addresses)
- IPv6  (Supports Internet Protocol version 6 addresses)
- MAC (Supports Media Access Control addresses)
- password  (Supports passwords that are minimum eight characters, at least one upper case English letter, one lower case English letter, one number and one special character. Or the litteral string "password")
- phone ( Supports phone numbers in the following formats: +xxxxxxxxxxx , +xxxxxxxxxxxxx , xxxxxxxxxx , xxx-xxx-xxxx)
- port  (Supports network ports 0-65535)
- SSN (Social Security Numbers xxx-xx-xxxx)
- time  (Supports 12/24 hour time formats: xx:xx am/pm (case insensitive), x:xx am/pm (case insensitive), xx:xx (24hr)
- URL (Supports most Uniform Resource Locators)

## Disclaimer / Warning
The contents of this module may allow the execution of the Invoke-Expression cmdlet on an arbitrary user input. Do not permit user access to this module if Invoke-Expression is disabled. Any misuse of this repository will not be the responsibility of the author or of any other collaborator.

## Credits

Credit to [geongeorge](https://github.com/geongeorge/i-hate-regex) for a lot of Regex.

Credit to [dfinke](https://github.com/dfinke) for ImportExcel.

## License

[GPL-3.0 License](https://github.com/JoustingZebra/Project-Birddog/blob/main/LICENSE)

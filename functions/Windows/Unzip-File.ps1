<#
$Metadata = @{
	Title = "Unzip File"
	Filename = "Unzip-File.ps1"
	Description = ""
	Tags = "powershell, function, unzip, file"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-04-22"
	LastEditDate = "2014-04-22"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>


function Unzip-File{

<#
.SYNOPSIS
   Unzip-File is a function which extracts the contents of a zip file.

.DESCRIPTION
	Unzip-File is a function which extracts the contents of a zip file specified via the -File parameter to the
	location specified via the -Destination parameter. This function first checks to see if the .NET Framework 4.5
	is installed and uses it for the unzipping process, otherwise COM is used.

.PARAMETER File
    The complete path and name of the zip file in this format: C:\zipfiles\myzipfile.zip 
 
.PARAMETER Destination
    The destination folder to extract the contents of the zip file to. If a path is no specified, the current path
	is used.

.PARAMETER ForceCOM
    Switch parameter to force the use of COM for the extraction even if the .NET Framework 4.5 is present.

.EXAMPLE
   Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\

.EXAMPLE
   Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\ -ForceCOM

.EXAMPLE
   'C:\zipfiles\AdventureWorks2012_Database.zip' | Unzip-File

.EXAMPLE
    Get-ChildItem -Path C:\zipfiles | ForEach-Object {$_.fullname | Unzip-File -Destination C:\databases}

.INPUTS
   String

.OUTPUTS
   None

.NOTES
   Author:  Mike F Robbins
   Website: http://mikefrobbins.com
   Twitter: @mikefrobbins

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({
            If((Test-Path -Path $_ -PathType Leaf) -and ($_ -like "*.zip")){
			
                $true
				
            }else{
			
                Throw "$_ is not a valid zip file. Enter in 'c:\folder\file.zip' format"
            }
        })]
        [string]$File,

        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            If (Test-Path -Path $_ -PathType Container){
			
                $true
				
            }else{
			
                Throw "$_ is not a valid destination folder. Enter in 'c:\destination' format"
            }
        })]
        [string]$Destination = (Get-Location).Path,

        [switch]$ForceCOM
    )


    If(-not $ForceCOM -and ($PSVersionTable.PSVersion.Major -ge 3) -and
       ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -like "4.5*" -or
       (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -like "4.5*")
	){

        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using .NET 4.5"

		[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$File", "$Destination")

    }else{

        Write-Verbose -Message "Attempting to Unzip $File to location $Destination using COM"

		$shell = New-Object -ComObject Shell.Application
		$shell.Namespace($destination).copyhere(($shell.NameSpace($file)).items())
    }
}
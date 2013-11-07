<#
$Metadata = @{
	Title = "Import PowerShell Credential"
	Filename = "Import-PSCredential.ps1"
	Description = "Import PowerShell credentials from a xml file"
	Tags = "powershell, import, credential"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-08-23"
	LastEditDate = "2013-11-07"
	Url = ""
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Import-PSCredential{

<#
.SYNOPSIS
    Import PowerShell credentials from a xml file.

.DESCRIPTION
	Export PowerShell credentials to a xml file.

.PARAMETER  Path
	Path to the import file. not required. default is "temp.credentials.config.xml"

.EXAMPLE
	PS C:\> Import-PSCredential -Path "C:\temp\temp.xml"
#>

	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Path = "temp.credentials.config.xml"
	)

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
	# Import credential file
	$Import = Import-Clixml $Path 
	
	# Test for valid import
	if ( !$Import.UserName -or !$import.EncryptedPassword ) {
		Throw "Input is not a valid ExportedPSCredential object, exiting."
	}

    # get username
	$Username = $Import.Username
	
	# Decrypt the password and store as a SecureString object for safekeeping
	$SecurePassword = $Import.EncryptedPassword | ConvertTo-SecureString
	
	# Build the new credential object
	$Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePassword
	Write-Output $Credential
}
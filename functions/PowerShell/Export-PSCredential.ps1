<#
$Metadata = @{
	Title = "Export PowerShell Credential"
	Filename = "Export-PSCredentials.ps1"
	Description = "Export PowerShell credentials to a xml file"
	Tags = "powershell, export, credential"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-08-23"
	LastEditDate = "2013-08-23"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Export-PSCredential{

<#
.SYNOPSIS
    Export PowerShell credentials to a xml file.

.DESCRIPTION
	Export PowerShell credentials to a xml file.

.PARAMETER  Credential
	PowerShell credential or a username. required.

.PARAMETER  Path
	Path to the export folder. not required. default is current location.

.PARAMETER  FileName
	Name of the exported file. not required. default is set.

.EXAMPLE
	PS C:\> Export-PSCredential -Credential (Get-Credential) -Path "C:\temp" -FileName "temp.xml"
#>

	param(
        [Parameter(Mandatory=$true)]
		$Credential = (Get-Credential),

        [Parameter(Mandatory=$false)]
		[String]
		$FileName = "temp.credentials.config.xml",

        [Parameter(Mandatory=$false)]
		[String]
		$Path
	)

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # Check export path parameter
    if($Path -ne ""){if(!(Test-Path -Path $Path)){New-Item $Path -Type Directory}}

    # Check credential parameter
	switch ( $Credential.GetType().Name ) {

		PSCredential{ 
			continue
		}

		String{
			$Credential = Get-Credential -credential $Credential 
		}

		default{ 
            Throw "You must specify a credential object to export." }
	}
	
	# Create temporary object to be serialized to disk
	$Export = "" | Select-Object Username, EncryptedPassword
	
	# give custom object a type name which can be identified later
	$Export.PSObject.TypeNames.Insert(0,’ExportedPSCredential’)
	
    # Add Username to custom export object
	$Export.Username = $Credential.Username

	# Encrypt SecureString password using Data Protection API
	# Only the current user account can decrypt this cipher
	$Export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString

    # Create export filepath
    if($Path -ne ""){
        $FilePath = Join-Path -Path $Path -ChildPath $FileName
    }else{
        $FilePath = $FileName
    }

	# Export using the Export-Clixml cmdlet
	$Export | Export-Clixml $FilePath

	# Return FileInfo object referring to saved credentials
	Get-Item $FilePath
}
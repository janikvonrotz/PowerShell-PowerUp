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
	LastEditDate = "2013-11-07"
	Version = "1.0.1"
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
	Path to the export file. not required. default is current location.

.EXAMPLE
	PS C:\> Export-PSCredential -Credential (Get-Credential) -Path "C:\temp\temp.xml"
	PS C:\> Export-PSCredential -Credential (Get-Credential) -Path "C:\yolo\"
    PS C:\> Export-PSCredential -Credential (Get-Credential)
#>

	param(
        [Parameter(Mandatory=$true)]
		$Credential = (Get-Credential),

        [Parameter(Mandatory=$false)]
		[String]
		$Path
	)

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
	switch ($Credential.GetType().Name) {

		PSCredential{ 

			continue
		}

		String{

			$Credential = Get-Credential -credential $Credential 
		}

		default{ 

            Throw "You must specify a credential object to export." }
	}	

	$Export = "" | Select-Object Username, EncryptedPassword
	$Export.PSObject.TypeNames.Insert(0,"ExportedPSCredential")	
	$Export.Username = $Credential.Username
	$Export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString

    if($Path -ne ""){

        if($Path.EndsWith("\")){
            
             $Path = $Path + "temp.credential.config.xml"
        }

        if(!(Test-Path (Split-Path $Path -Parent))){New-Item -ItemType directory -Path (Split-Path $Path -Parent) | Out-Null}
    
    }else{
               
        $Path = "temp.credential.config.xml"
    }

	$Export | Export-Clixml $Path

	Get-Item $Path
}
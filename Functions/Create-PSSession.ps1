$Metadata = @{
	Title = "Create Powershell Remote Session"
	Filename = "Create-PSSession.ps1"
	Description = ""
	Tags = "powershell, remote, session"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "12.03.2013"
	LastEditDate = "12.03.2013"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example Create-PSSession.config.json.ps1
#--------------------------------------------------#

return $Content = @"
{
	"Servers":[
		{ 
		"Name": "sharepoint",
		"Server": "windows1.local.com", 
		"ADCredential":"vbl\\user",
		"SnapIns": ["Microsoft.SharePoint.PowerShell"]
		},
		{ 
		"Name": "sharepoint2",
		"Server": "windows2.local.com", 
		"ADCredential":"vbl\\user",
		"SnapIns": ["Microsoft.SharePoint.PowerShell","ActiveDirectory"]
		}
	]
}
"@

 
#>

function Create-PSSession{
	param (
        [parameter(Mandatory=$true)]
		$Name
	)
	
	# Settings
	$Config = Get-JsonConfig -Path ".\Create-PSSession.config.json.ps1" 

	foreach($Server in $Config.Servers){
		if($Server.Name -eq $Name){
			$s = New-PSSession -ComputerName $Server.Server -Credential $Server.ADCredential
			foreach($SnapIn in $Server.SnapIns){
				Invoke-Command -Session $s -ScriptBlock {param ($Name) Add-PSSnapin -Name $Name} -ArgumentList $SnapIn
			}
            return $s
		}
	}
}
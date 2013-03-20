$Metadata = @{
	Title = "Create Powershell Remote Session"
	Filename = "Create-PSSession.ps1"
	Description = ""
	Tags = "powershell, remote, session"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-12"
	LastEditDate = "2013-03-19"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example Create-PSSession.config.json.ps1 in the profile folder
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
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
		$Name
	)
	
	#--------------------------------------------------#
	# Settings
	#--------------------------------------------------#
	$ConfigFile = "Create-PSSession.config.json.ps1"
	$ProfilePath = Split-Path $profile -parent
	$Config = Get-JsonConfig -Path ($ProfilePath + "\" + $ConfigFile)
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	foreach($Server in $Config.Servers){
		if($Server.Name -eq $Name){
		
			# Delete Session if already opened
			Remove-PSSession -ComputerName $Server.Server -ErrorAction SilentlyContinue
			
			$Username = $Server.ADCredential
			$Password = Read-Host -Prompt "`nEnter password for $Username" -AsSecureString
			$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password
			
			# Open Session
			$s = New-PSSession -ComputerName $Server.Server -Credential $Credentials
			
			# Load SnapIns
			foreach($SnapIn in $Server.SnapIns){
				Invoke-Command -Session $s -ScriptBlock {param ($Name) Add-PSSnapin -Name $Name} -ArgumentList $SnapIn
			}
            return $s
		}
	}
}
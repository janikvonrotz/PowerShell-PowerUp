<#
$Metadata = @{
	Title = "Disable User Access Control"
	Filename = "Disable-UserAccessControl.ps1"
	Description = ""
	Tags = "powershell, disable, windows, user, access, control, prompt"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-12-17"
	LastEditDate = "2014-02-23"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Disable-UserAccessControl{

<#
.SYNOPSIS
    Disable UAC feature.

.DESCRIPTION
	Disable User Access Control feature.

.EXAMPLE
	PS C:\> Disable-UserAccessControl
#>

	[CmdletBinding()]
	param(
        
	)
    
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	
	Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000
	if(Get-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name "EnableLUA"  -ErrorAction SilentlyContinue){
		Set-ItemProperty "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name "EnableLUA" -Value 00000000
    }
	Write-Host "User Access Control (UAC) has been disabled. Reboot required."
}
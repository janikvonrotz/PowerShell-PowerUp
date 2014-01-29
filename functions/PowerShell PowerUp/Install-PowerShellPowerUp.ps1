<#
$Metadata = @{
	Title = "Install PowerShell PowerUp"
	Filename = "Install-PowerShellPowerUp.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-15"
	LastEditDate = "2014-01-29"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Install-PowerShellPowerUp{

<#
.SYNOPSIS
	Install PowerShell PowerUp.

.DESCRIPTION
	This functions runs the installer script of the PowerShell PowerUp script.
	
.PARAMETER Force
	Overwrites configuration files even if the already exist.
	
.EXAMPLE
	PS C:\> Install-PowerShellPowerUp -Force
#>

	param(
		[switch]
		$Force
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	Set-Location $PSprofile.Path
	Invoke-Expression "$($PSProfile.Install.FullName) -Force:`$Force"
	Set-Location $WorkingPath
}
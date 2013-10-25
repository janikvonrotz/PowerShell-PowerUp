<#
$Metadata = @{
	Title = "Install PowerShell Profile"
	Filename = "Install-PowerShellProfile.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-15"
	LastEditDate = "2013-10-15"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Install-PowerShellProfile{

<#
.SYNOPSIS
	Install PowerShell Profile.

.DESCRIPTION
	This functions runs the installer script of the PowerShell Profile script.

.EXAMPLE
	PS C:\> Install-PowerShellProfile
#>

	param(
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	sl $PSprofile.Path
	iex $PSProfile.Install.FullName
	sl $WorkingPath
}
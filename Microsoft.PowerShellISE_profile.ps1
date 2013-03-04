$Metadata = @{
	Title = "Powershell ISE Profile"
	Filename = "Microsoft.PowerShellISE_profile.ps1"
	Description = "[Description]"
	Tags = "powershell, ise, profile"
	Project = "[Projectname]"
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "02.01.2013"
	LastEditDate = "04.03.2013"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# Settings
#--------------------------------------------------#

[string]$WorkingPath = Get-Location
$ScriptPath = Split-Path $MyInvocation.MyCommand.Definition -Parent
$FunctionPath = "\Functions"

#--------------------------------------------------#
# Includes
#--------------------------------------------------#
Set-Location ($ScriptPath + $FunctionPath)
get-childitem | foreach {. .\$_}

#--------------------------------------------------#
# Main Code
#--------------------------------------------------#

# Go back to working directory
Set-Location $WorkingPath
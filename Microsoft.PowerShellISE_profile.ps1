$Metadata = @{
	Title = "Powershell ISE Profile"
	Filename = "Microsoft.PowerShellISE_profile.ps1"
	Description = ""
	Tags = "powershell, ise, profile"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04.03"
	LastEditDate = "2013-04.03"
	Version = "2.0.1"
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
# Alias
#--------------------------------------------------#	
nal -Name rdp -Value "Start-RDPSession"

#--------------------------------------------------#
# Main Code
#--------------------------------------------------#

# Go back to working directory
Set-Location $WorkingPath
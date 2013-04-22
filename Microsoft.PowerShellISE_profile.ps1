    
$Metadata = @{
	Title = "Powershell ISE Profile"
	Filename = "Microsoft.PowerShellISE_profile.ps1"
	Description = ""
	Tags = "powershell, ise, profile"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-22"
	LastEditDate = "2013-04-22"
	Version = "3.1.0"
	License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

#--------------------------------------------------#
# Main
#--------------------------------------------------#
[string]$WorkingPath = Get-Location
$PSConfig = "\Microsoft.PowerShell_profile.config.ps1"
$PathToScript = Split-Path $MyInvocation.MyCommand.Definition -Parent
$PSConfig = Invoke-Expression ($PathToScript + $PSConfig)

#--------------------------------------------------#
# Autoinclude Functions
#--------------------------------------------------#
$IncludeFolders = @()
$IncludeFolders += $PSConfig.functions.Path
$IncludeFolders += get-childitem ($PSConfig.functions.Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
foreach ($IncludeFolder in $IncludeFolders){
	Set-Location $IncludeFolder
	get-childitem $IncludeFolder | where{ ! $_.PSIsContainer} | foreach {. .\$_}
}

#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------#	
nal -Name rdp -Value "Connect-RDPSession"
nal -Name rps -Value "Connect-PSSession"

#--------------------------------------------------#
# Main End
#--------------------------------------------------#
Set-Location $WorkingPath


    
$Metadata = @{
	Title = "Powershell Profile"
	Filename = "Microsoft.PowerShell_profile.ps1"
	Description = ""
	Tags = "powershell, profile"
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
# Custom PowerShell CLI
#--------------------------------------------------#
$PromptSettings = (Get-Host).UI.RawUI
# $PromptSettings.ForegroundColor = "Black"
# $PromptSettings.BackgroundColor = "White"
$PromptSettings.BufferSize.Width = 120
$PromptSettings.BufferSize.Height = 999
$PromptSettings.WindowSize.Width = 120
$PromptSettings.WindowSize.Height = 50
$PromptSettings.MaxWindowSize.Width = 120
$PromptSettings.MaxWindowSize.Height = 50
$PromptSettings.MaxPhysicalWindowSize.Width = 120
$PromptSettings.MaxPhysicalWindowSize.Height = 50
# $PromptSettings.WindowTitle = "PowerShell"

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
# Transcript Logging
#--------------------------------------------------#	
Start-Transcript -path ($PSConfig.logs.Path + "\Powershell Commands " + $(Get-LogStamp) + ".txt")

#--------------------------------------------------#
# Main End
#--------------------------------------------------#
Set-Location $WorkingPath


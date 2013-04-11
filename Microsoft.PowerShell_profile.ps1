$Metadata = @{
	Title = "Powershell Profile"
	Filename = "Microsoft.PowerShell_profile.ps1"
	Description = ""
	Tags = "powershell, profile"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04.03"
	LastEditDate = "2013-04-08"
	Version = "2.0.2"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# Settings
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

[string]$WorkingPath = Get-Location
$ScriptPath = Split-Path $MyInvocation.MyCommand.Definition -Parent
$FunctionPath = "\functions"

#--------------------------------------------------#
# Includes
#--------------------------------------------------#
$IncludeFolders = @()
$IncludeFolders += $ScriptPath + $FunctionPath
$IncludeFolders += get-childitem ($ScriptPath + $FunctionPath) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
foreach ($IncludeFolder in $IncludeFolders){
	Set-Location $IncludeFolder
	get-childitem | where{ ! $_.PSIsContainer} | foreach {. .\$_}
}


#--------------------------------------------------#
# Alias
#--------------------------------------------------#	
nal -Name rdp -Value "Start-RDPSession"
nal -Name rps -Value "Create-PSSession"

#--------------------------------------------------#
# Main Code
#--------------------------------------------------#
# Logging
Start-Transcript -path ($ScriptPath + "\Logs\Powershell Commands " + $(Get-LogStamp) + ".txt")

# Go back to working directory
Set-Location $WorkingPath
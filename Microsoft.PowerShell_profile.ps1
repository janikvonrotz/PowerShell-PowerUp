$Metadata = @{
	Title = "Powershell Profile"
	Filename = "Microsoft.PowerShell_profile.ps1"
	Description = ""
	Tags = "powershell, profile"
	Project = ""
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
$FunctionPath = "\Functions"

#--------------------------------------------------#
# Includes
#--------------------------------------------------#
Set-Location ($ScriptPath + $FunctionPath)
get-childitem | foreach {. .\$_}

#--------------------------------------------------#
# Main Code
#--------------------------------------------------#
# Logging
Start-Transcript -path ($ScriptPath + "\Logs\Powershell Commands " + $(Get-LogStamp) + ".txt")

# Go back to working directory
Set-Location $WorkingPath

# Load posh-git example profile
# . 'C:\Users\vonrotz\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'


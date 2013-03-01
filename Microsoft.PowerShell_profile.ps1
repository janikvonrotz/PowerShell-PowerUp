#--------------------------------------------------#
#  Title: Powershell Profile
#--------------------------------------------------#
#  File name: Microsoft.PowerShell_profile.ps1
#  Description: [Description]
#  Tags: powershell, profile
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 02.01.2013
#  Last Edit Date: 18.02.2013
#  Version: 1.1.2
#
#  License: 
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

 #UI Settings
$PromptSettings = (Get-Host).UI.RawUI
$PromptSettings.ForegroundColor = "Black"
$PromptSettings.BackgroundColor = "White"
$PromptSettings.BufferSize.Width = 120
$PromptSettings.BufferSize.Height = 999
$PromptSettings.WindowSize.Width = 120
$PromptSettings.WindowSize.Height = 50
$PromptSettings.MaxWindowSize.Width = 120
$PromptSettings.MaxWindowSize.Height = 50
$PromptSettings.MaxPhysicalWindowSize.Width = 120
$PromptSettings.MaxPhysicalWindowSize.Height = 50
$PromptSettings.WindowTitle = "PowerShell"

 # Settings
$WorkingPath = Get-Location
$ScriptPath = Split-Path $MyInvocation.MyCommand.Definition -Parent
$FunctionPath = "\Functions"

 # Include Functions
Set-Location ($ScriptPath + $FunctionPath)
get-childitem | foreach {. .\$_}

 # Logging
Start-Transcript -path ($ScriptPath + "\Logs\Powershell Commands " + $(Get-LogStamp) + ".txt")

 # Go back to working directory
Set-Location $ScriptPath

 # LoadConfig
$Configuration = Get-XmlConfig Config.xml


 # Add System Variables
foreach ($SystemVariable in $Configuration.SystemVariables.SystemVariable)
{
	if($SystemVariable.RelativePath -eq "true")
	{
		Set-Location $SystemVariable.Path
		New-SystemVariable -Path $(Get-Location) -Name $SystemVariable.Name
		 # Go back to working directory
		Set-Location $ScriptPath
	}else{
		New-SystemVariable -Path $SystemVariable.Path -Name $SystemVariable.Name
	}
}

 # Go back to working directory
Set-Location $WorkingPath

 # Clear Screen
#clear


#--------------------------------------------------#
#  Title: Profile Installation
#--------------------------------------------------#
#  File name: ProfileInstallation.ps1
#  Description: [Description]
#  Tags: powershell, profile, installation
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 07.01.2013
#  Last Edit Date: 18.02.2013
#  Version: 1.1.3
#
#  License: 
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

 # Settings
[string]$TargetPath = Get-Location
$WorkingPath = Get-Location
$ModulesFolderName = "Modules"
$FunctionPath = "\Functions"

 # Include
Set-Location ($TargetPath + $FunctionPath)
get-childitem | foreach {. .\$_}
Set-Location ..

 # Create Profile
if (!(Test-Path $profile)){

	  # Create a profile
	New-Item -path $profile -type file -force
}

 # Link Powershell Profile
$SourcePath = Split-Path $profile -parent
$ScriptName = $MyInvocation.MyCommand.Name

if (!(Test-Path ($SourcePath + "\" + $ScriptName) -PathType Leaf))
{
	 # Rename default source
	Rename-Item $SourcePath ($SourcePath + "-Obsolete")
	 
	 # Create a shortcut to the existing powershell profile
	New-Symlink $SourcePath $TargetPath
}

 # LoadConfig
$Configuration = Get-XmlConfig Config.xml

 # Registry Settings
Set-Location HKCU:\
foreach ($RegistryEntry in $Configuration.RegistryEntries.RegistryEntry)
{
	Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
}

 # Go back to working directory
Set-Location $WorkingPath
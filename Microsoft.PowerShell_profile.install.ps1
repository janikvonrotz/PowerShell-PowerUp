$Metadata = @{
    Title = "Profile Installation"
    Filename = "Microsoft.PowerShell_profile.install.ps1"
    Description = ""
    Tags = "powershell, profile, installation"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "www.janikvonrotz.ch"
    CreateDate = "2013-03-18"
    LastEditDate = "2013-09-13"
    Version = "6.0.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

# check compatiblity
if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}

# store this path
Push-Location -StackName "WorkingPath"

#--------------------------------------------------#
# PowerShell Profile
#--------------------------------------------------#
# Create PowerShell Profile
if (!(Test-Path $Profile)){

    # Create a profile
    Write-Host "Add a default profile script"
	New-Item -path $Profile -type file -force
}

#--------------------------------------------------#
#  settings
#--------------------------------------------------#
    
# load global configurations
.\Microsoft.PowerShell_profile.config.ps1
$PSProfilePath = (Get-Location).Path

#--------------------------------------------------#
#  prerequisites
#--------------------------------------------------#

# install chocolatey
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# install modules with chocolatey
& C:\Chocolatey\bin\cinst.bat psget -force

Import-Module "C:\Program Files\Common Files\Modules\PsGet\PsGet.psm1"

Install-Module pscx

Import-Module pscx

#--------------------------------------------------#
# autoinclude functions
#--------------------------------------------------#
Get-childitem ($PSfunctions.Path) -Recurse | where{-not $_.PSIsContainer} | foreach{. ($_.Fullname)}
    
#--------------------------------------------------#
# load profile configs
#--------------------------------------------------#
    
# load configuration files
Get-ChildItem -Path $PSconfigs.Path -Filter "*.profile.config.xml" -Recurse |
     %{[xml]$(get-content $_.FullName)} |
         %{$Features += $_.Content.Feature;$Systemvariables += $_.Content.Systemvariable}

#--------------------------------------------------#
# add system variables
#--------------------------------------------------#
    
$SystemVariables | %{
        
    Write-Host ("Adding path variable: " + $_.Value)
        
    if($_.RelativePath -eq "true"){
        
        Add-PathVariable -Value (Convert-Path -Path (Join-Path -Path $(Get-Location).Path -Childpath $_.Value)) -Name $_.Name -Target $_.Target
            
    }else{            
            
        Add-PathVariable -Value (Invoke-Expression ($Command = '"' + $_.Value + '"')) -Name $_.Name -Target $_.Target
    }
}
    	
#--------------------------------------------------#
# features
#--------------------------------------------------#

# Metadata
$PSContent += @'
    
$Metadata = @{
Title = "Powershell Profile"
Filename = "Microsoft.PowerShell_profile.ps1"
Description = ""
Tags = "powershell, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "www.janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2013-09-13"
Version = "5.0.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
    
# Metadata ISE    
$PSContentISE += @'
    
$Metadata = @{
Title = "Powershell ISE Profile"
Filename = "Microsoft.PowerShellISE_profile.ps1"
Description = ""
Tags = "powershell, ise, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "www.janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2013-09-13"
Version = "5.0.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
     
#--------------------------------------------------#
# Git Update Task
#--------------------------------------------------#
if($Features | Where{$_.Name -eq "Git Update Task"}){	
    			
	Add-SheduledTask -Title "Git Update Task" -Command "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Arguments (Get-ChildItem -Path $PSconfigs.Path -Filter "Git-Update.ps1" -Recurse).Fullname -WorkingDirectory $WorkingPath -XMLFilename "Git-Update.task.config"
}
 
#--------------------------------------------------#
# Powershell Remoting
#--------------------------------------------------# 
if($Features | Where{$_.Name -eq "Powershell Remoting"}){
    
    Write-Host "Enabling Powershell Remoting"
	Enable-PSRemoting
	Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
	Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
	restart-Service WinRM		
}

#--------------------------------------------------#
# Enable Open Powershell here
#--------------------------------------------------#  
if($Features | Where{$_.Name -eq "Enable Open Powershell here"}){
    
    Write-Host "Adding 'Open PowerShell Here' to context menu "
	$Null = Enable-OpenPowerShellHere
		
}
 
#--------------------------------------------------#
# Path System Variable For App Subfolders
#--------------------------------------------------#     
if($Features | Where{$_.Name -eq "Path System Variable For App Subfolders"}){
    
	Get-ChildItem $PSapps.Path -Force | Where {$_.PSIsContainer} | %{
        
        Write-Host ("Adding path variable: " + $_.Name)
        Add-PathVariable -Value $_.Fullname -Name "Path" -Target "Machine"
        
    }
}

$PSContent += $Content = @'

#--------------------------------------------------#
# main
#--------------------------------------------------#
Push-Location -StackName "WorkingPath"
. 
'@ + (Join-Path -Path $PSProfilePath -ChildPath "Microsoft.PowerShell_profile.config.ps1") + @'

'@

$PSContentISE += $Content

if($Features | Where{$_.Name -eq "Custom PowerShell CLI"}){
    Write-Host "Add Custom PowerShell CLI to the profile script"
	$PSContent += @'

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

'@
}
 
if($Features | Where{$_.Name -eq "Autoinclude Functions"}){
    Write-Host "Add Autoinclude Functions to the profile script"
	$PSContent += $Content = @'

#--------------------------------------------------#
# Autoinclude Functions
#--------------------------------------------------#
Get-childitem ($PSfunctions.Path) -Recurse | where{-not $_.PSIsContainer} | foreach{. ($_.Fullname)}

'@
    $PSContentISE += $Content
}
    
#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------# 
if($Features | Where{$_.Name -eq "Custom Aliases"}){
    Write-Host "Add Custom Aliases to the profile script"
	$PSContent += $Content = @'

#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------#	
nal -Name crdp -Value "Connect-RDPSession" -ErrorAction SilentlyContinue
nal -Name crps -Value "Connect-PSSession" -ErrorAction SilentlyContinue
nal -Name chttp -Value "Connect-HttpSession" -ErrorAction SilentlyContinue
nal -Name cssh -Value "Connect-SSHSession" -ErrorAction SilentlyContinue
nal -Name cscp -Value "Connect-SCPSession" -ErrorAction SilentlyContinue
nal -Name cftp -Value "Connect-FTPSession" -ErrorAction SilentlyContinue

'@
    $PSContentISE += $Content
}

if($Features | Where{$_.Name -eq "Transcript Logging"}){
    Write-Host "Add Transcript Logging to the profile script"
	$PSContent += @'

#--------------------------------------------------#
# Transcript Logging
#--------------------------------------------------#	
Start-Transcript -path ($PSlogs.Path + "\PowerShell Session " + $((get-date -format o) -replace ":","-") + " " + $env:COMPUTERNAME  + "-" + $env:USERNAME  + ".txt")
Write-Host ""

'@
}

if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Run -contains "asDailyJob")}){

    Add-SheduledTask -Title "Log File Retention Task" -Command "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Arguments $(Get-ChildItem -Path $PSconfigs.Path -Filter "Delete-ObsoleteLogFiles.ps1" -Recurse).FullName -WorkingDirectory $WorkingPath -XMLFilename "Delete-ObsoleteLogFiles.task.config"
        
}
   
if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Run -contains "withProfileScript")}){
                    
    Write-Host "Add Log File Retention to the profile script"
    $PSContent += $Content = @'

#--------------------------------------------------#
# Log File Retention
#--------------------------------------------------#	
& $(Get-ChildItem -Path $PSconfigs.Path -Filter "Delete-ObsoleteLogFiles.ps1" -Recurse).Fullname

'@
    $PSContentISE += $Content
}

if($Features | Where{$_.Name -eq "Get Quote Of The Day"}){
    Write-Host "Add Get Quote Of The Day to the profile script"
	$PSContent += $Content = @'

#--------------------------------------------------#
# Get Quote Of The Day
#--------------------------------------------------#	
Get-QuoteOfTheDay
Write-Host ""

'@
    $PSContentISE += $Content
}

$PSContent += $Content = @'

#--------------------------------------------------#
# main end
#--------------------------------------------------#
Pop-Location -StackName "WorkingPath"

'@
$PSContentISE += $Content
    
#--------------------------------------------------#
# Multi Remote Management
#--------------------------------------------------#  
if($Features | Where{$_.Name -eq "Multi Remote Management"}){
    			
    # RDP Default file
    $DefaultRDP = @'
screen mode id:i:1
use multimon:i:0
desktopwidth:i:1600
desktopheight:i:1024
session bpp:i:32
winposstr:s:0,1,155,144,1628,1032
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:2
displayconnectionbar:i:1
disable wallpaper:i:1
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
full address:s:
audiomode:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
redirectclipboard:i:1
redirectposdevices:i:0
redirectdirectx:i:1
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:1
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:1
use redirection server name:i:0
drivestoredirect:s:
'@
    # Write content to config file only if note exist
	$DefaultRDPFilePath  = Join-Path -Path $PSconfigs.Path -ChildPath "Default.rdp"
    if(!(test-path $DefaultRDPFilePath)){
        Write-Host "Adding Default RDP file to the config folder"
		Set-Content -Value $DefaultRDP -Path $DefaultRDPFilePath
	}
}

# Write content to script file
Write-Host "Creating PowerShell Profile Script"
Set-Content -Value $PSContent -Path $Profile
    
#--------------------------------------------------#
# Add ISE Profile Script
#--------------------------------------------------#
if($Features | Where{$_.Name -eq "Add ISE Profile Script"}){
    Write-Host "Creating PowerShell ISE Profile Script"
    Set-Content -Value $PSContentISE -Path (Join-Path -Path (Split-Path $profile -Parent) -ChildPath "Microsoft.PowerShellISE_profile.ps1")
}




# link the new PowerShell Profile
if (-not (Test-Path $MyInvocation.InvocationName -PathType Leaf)){

    Write-Host "Redirect Default PowerShell Profile script to custom PowerShell Profile script"
        
	# Rename default source
	Rename-Item $profile ($profile + "-Obsolete")
 
	# Create a shortcut to the existing powershell profile
	New-Symlink  (Split-Path $profile -Parent) (Split-Path $MyInvocation.InvocationName -Parent)
}
#>

Pop-Location -StackName "WorkingPath"
Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
Read-Host "Press Enter to exit"
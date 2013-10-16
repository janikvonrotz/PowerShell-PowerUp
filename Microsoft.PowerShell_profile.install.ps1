$Metadata = @{
    Title = "Profile Installation"
    Filename = "Microsoft.PowerShell_profile.install.ps1"
    Description = ""
    Tags = "powershell, profile, installation"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "www.janikvonrotz.ch"
    CreateDate = "2013-03-18"
    LastEditDate = "2013-10-08"
    Version = "5.1.0"
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
$PSProfileConfig = Join-Path -Path (Get-Location).Path -ChildPath "Microsoft.PowerShell_profile.config.ps1"
if((Test-Path $PSProfileConfig) -and $PSProfile -eq $null){
    iex $PSProfileConfig
}elseif($PSProfile -ne $null){
	Write-Host "Using global configuration of this session"
}elseif(-not (Test-Path $PSProfileConfig)){
    throw "Couldn't find $PSProfileConfig"
}

#--------------------------------------------------#
#  prerequisites
#--------------------------------------------------#

# install chocolatey
if(!(Get-Command "cinst" -ErrorAction SilentlyContinue)){
	iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

if(!(Get-Module -ListAvailable | where{$_.Name -eq "PsGet"})){

    # install module with chocolatey
    & C:\Chocolatey\bin\cinst.bat psget -force

    # import module with static path
    Import-Module "C:\Program Files\Common Files\Modules\PsGet\PsGet.psm1"

}else{

    Import-Module PsGet
}

if(!(Get-Module -ListAvailable | where{$_.Name -eq "pscx"})){

    # install module with PsGet
    Install-Module pscx
}

Import-Module pscx

#--------------------------------------------------#
# autoinclude functions
#--------------------------------------------------#
Get-childitem ($PSfunctions.Path) -Recurse | where{-not $_.PSIsContainer} | foreach{. ($_.Fullname)}
    
#--------------------------------------------------#
# load profile configs
#--------------------------------------------------#

# load configuration files
Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Profile.Filter -Recurse |
     %{[xml]$(get-content $_.FullName)} |
         %{$Features += $_.Content.Feature;$Systemvariables += $_.Content.Systemvariable}

#--------------------------------------------------#
# add system variables
#--------------------------------------------------#
if($SystemVariables -ne $Null){$SystemVariables | %{
        
        Write-Host ("Adding path variable: $($_.Value)")
        
        if($_.RelativePath -eq "true"){
        
            Add-PathVariable -Value (Convert-Path -Path (Join-Path -Path $(Get-Location).Path -Childpath $_.Value)) -Name $_.Name -Target $_.Target
            
        }else{            
            
            Add-PathVariable -Value (Invoke-Expression ($Command = '"' + $_.Value + '"')) -Name $_.Name -Target $_.Target
        }
    }
}	

#--------------------------------------------------#
# features
#--------------------------------------------------#

# Metadata
$PSPContent += @'
    
$Metadata = @{
Title = "Powershell Profile"
Filename = "Microsoft.PowerShell_profile.ps1"
Description = ""
Tags = "powershell, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "www.janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2013-10-08"
Version = "5.1.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
    
# Metadata ISE    
$PSPContentISE += @'
    
$Metadata = @{
Title = "Powershell ISE Profile"
Filename = "Microsoft.PowerShellISE_profile.ps1"
Description = ""
Tags = "powershell, ise, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "www.janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2013-10-08"
Version = "5.1.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
     
#--------------------------------------------------#
# Git Update
#--------------------------------------------------#
if($Features | Where{$_.Name -eq "Git Update"}){
   
    Update-PowerShellProfile
    
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.GitUpdate.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.GitUpdate.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.GitUpdate.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.GitUpdate.Name)
	}
    
    Update-ScheduledTask
}

#--------------------------------------------------#
# Powershell Remoting
#--------------------------------------------------# 
if($Features | Where{$_.Name -eq "Powershell Remoting"}){
    
    Write-Host "Enabling Powershell Remoting"
	Enable-PSRemoting -Confirm:$false
	Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
	Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
	restart-Service WinRM -Confirm:$false
}

#--------------------------------------------------#
# Enable Open Powershell here
#--------------------------------------------------#  
if($Features | Where{$_.Name -eq "Enable Open Powershell here"}){
    
    Write-Host "Adding 'Open PowerShell Here' to context menu "
	$Null = Enable-OpenPowerShellHere
		
}

$PSPContent += $Content = @'

#--------------------------------------------------#
# main
#--------------------------------------------------#
. '
'@ + (Join-Path -Path $PSProfile.Path -ChildPath "Microsoft.PowerShell_profile.config.ps1") + "'`n`n"

$PSPContentISE += $Content

if($Features | Where{$_.Name -eq "Custom PowerShell CLI"}){
    Write-Host "Add Custom PowerShell CLI to the profile script"
	$PSPContent += @'

#--------------------------------------------------#
# Custom PowerShell CLI
#--------------------------------------------------#
$PromptSettings = (Get-Host).UI.RawUI
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
	$PSPContent += $Content = @'

#--------------------------------------------------#
# Autoinclude Functions
#--------------------------------------------------#
Get-childitem ($PSfunctions.Path) -Recurse | where{-not $_.PSIsContainer} | foreach{. ($_.Fullname)}

'@
    $PSPContentISE += $Content
}
    
#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------# 
if($Features | Where{$_.Name -eq "Custom Aliases"}){
    Write-Host "Add Custom Aliases to the profile script"
	$PSPContent += $Content = @'

#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------#
nal -Name grc -Value "Get-RemoteConnection" -ErrorAction SilentlyContinue
nal -Name gppc -Value "Get-PPConfiguration" -ErrorAction SilentlyContinue	
nal -Name crdp -Value "Connect-RDP" -ErrorAction SilentlyContinue
nal -Name crps -Value "Connect-PSS" -ErrorAction SilentlyContinue
nal -Name chttp -Value "Connect-Http" -ErrorAction SilentlyContinue
nal -Name cssh -Value "Connect-SSH" -ErrorAction SilentlyContinue
nal -Name cscp -Value "Connect-SCP" -ErrorAction SilentlyContinue
nal -Name cftp -Value "Connect-FTP" -ErrorAction SilentlyContinue
nal -Name cvss -Value "Connect-VSphere" -ErrorAction SilentlyContinue
nal -Name cvm -Value "Connect-VM" -ErrorAction SilentlyContinue

'@
    $PSPContentISE += $Content
}

if($Features | Where{$_.Name -eq "Transcript Logging"}){
    Write-Host "Add Transcript Logging to the profile script"
	$PSPContent += @'

#--------------------------------------------------#
# Transcript Logging
#--------------------------------------------------#	
Start-Transcript -path $PSlogs.SessionFile
Write-Host ""

'@
}

if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Run -match "asDailyJob")}){

    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.LogFileRetention.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.LogFileRetention.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.LogFileRetention.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.LogFileRetention.Name)
	}
    
    Update-ScheduledTask
}
   
if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Run -match "withProfileScript")}){
                    
    Write-Host "Add Log File Retention to the profile script"
    $PSPContent += $Content = @'

#--------------------------------------------------#
# Log File Retention
#--------------------------------------------------#
Delete-ObsoleteLogFiles

'@
    $PSPContentISE += $Content
}

if($Features | Where{$_.Name -eq "Get Quote Of The Day"}){
    Write-Host "Add Get Quote Of The Day to the profile script"
	$PSPContent += $Content = @'

#--------------------------------------------------#
# Get Quote Of The Day
#--------------------------------------------------#	
Get-QuoteOfTheDay
Write-Host ""

'@
    $PSPContentISE += $Content
}

$PSPContent += $Content = @'

#--------------------------------------------------#
# main end
#--------------------------------------------------#
Set-Location $WorkingPath

'@
$PSPContentISE += $Content
    
#--------------------------------------------------#
# Multi Remote Management
#--------------------------------------------------#  
if($Features | Where{$_.Name -eq "Multi Remote Management"}){
       
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.RDP.Name -Recurse)){
    
        Write-Host "Copy $($PStemplates.RDP.Name) file to the config folder"        
		Copy-Item -Path $PStemplates.RDP.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.RDP.Name)
	}   

    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.WinSCP.Name -Recurse)){
    
        Write-Host "Copy $($PStemplates.WinSCP.Name) file to the config folder"        
		Copy-Item -Path $PStemplates.WinSCP.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.WinSCP.Name)
	}   
    
}

# Write content to script file
Write-Host "Creating PowerShell Profile Script"
Set-Content -Value $PSPContent -Path $Profile
    
#--------------------------------------------------#
# Add ISE Profile Script
#--------------------------------------------------#
if($Features | Where{$_.Name -eq "Add ISE Profile Script"}){
    Write-Host "Creating PowerShell ISE Profile Script"
    Set-Content -Value $PSPContentISE -Path (Join-Path -Path (Split-Path $profile -Parent) -ChildPath "Microsoft.PowerShellISE_profile.ps1")
}

Set-Location $WorkingPath

Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
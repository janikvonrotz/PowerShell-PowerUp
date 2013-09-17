$Metadata = @{
    Title = "Profile Installation"
    Filename = "Microsoft.PowerShell_profile.install.ps1"
    Description = ""
    Tags = "powershell, profile, installation"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "www.janikvonrotz.ch"
    CreateDate = "2013-03-18"
    LastEditDate = "2013-09-17"
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
if(!(Get-Command "cinst")){
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
Get-ChildItem -Path $PSconfigs.Path -Filter "*.profile.config.xml" -Recurse |
     %{[xml]$(get-content $_.FullName)} |
         %{$Features += $_.Content.Feature;$Systemvariables += $_.Content.Systemvariable}

#--------------------------------------------------#
# add system variables
#--------------------------------------------------#
    
if($SystemVariables -ne $Null){$SystemVariables | %{
        
        Write-Host ("Adding path variable: " + $_.Value)
        
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
LastEditDate = "2013-09-16"
Version = "5.0.0"
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
LastEditDate = "2013-09-16"
Version = "5.0.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
     
#--------------------------------------------------#
# Git Update Task
#--------------------------------------------------#
if($Features | Where{$_.Name -eq "Git Update Task"}){	
    
    if(!(Get-Command "git")){

        cinst git -force
    }

    if(!(Test-Path -Path (Join-Path -Path $PSProfilePath -ChildPath ".git"))){
    
        cd $PSProfilePath

        # initialise git repository
        git init
        git add remote origin "git://github.com/janikvonrotz/Powershell-Profile.git"
        git fetch origin
        git reset --hard origin/master


        Pop-Location -StackName "WorkingPath"

    }else{

        git fetch origin
        git reset --hard origin/master

    }
    			
	Add-SheduledTask -Title "Git Update Task" -Command "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Arguments (Get-ChildItem -Path $PSconfigs.Path -Filter "Git-Update.ps1" -Recurse).Fullname -WorkingDirectory $PSProfilePath -XMLFilename "Git-Update.task.config"
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

$PSPContent += $Content = @'

#--------------------------------------------------#
# main
#--------------------------------------------------#
Push-Location -StackName "WorkingPath"
. '
'@ + (Join-Path -Path $PSProfilePath -ChildPath "Microsoft.PowerShell_profile.config.ps1") + "'`n`n"

$PSPContentISE += $Content

if($Features | Where{$_.Name -eq "Custom PowerShell CLI"}){
    Write-Host "Add Custom PowerShell CLI to the profile script"
	$PSPContent += @'

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
nal -Name crdp -Value "Connect-RDPSession" -ErrorAction SilentlyContinue
nal -Name crps -Value "Connect-PSSession" -ErrorAction SilentlyContinue
nal -Name chttp -Value "Connect-HttpSession" -ErrorAction SilentlyContinue
nal -Name cssh -Value "Connect-SSHSession" -ErrorAction SilentlyContinue
nal -Name cscp -Value "Connect-SCPSession" -ErrorAction SilentlyContinue
nal -Name cftp -Value "Connect-FTPSession" -ErrorAction SilentlyContinue

'@
    $PSPContentISE += $Content
}

if($Features | Where{$_.Name -eq "Transcript Logging"}){
    Write-Host "Add Transcript Logging to the profile script"
	$PSPContent += @'

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
    $PSPContent += $Content = @'

#--------------------------------------------------#
# Log File Retention
#--------------------------------------------------#	
& $(Get-ChildItem -Path $PSconfigs.Path -Filter "Delete-ObsoleteLogFiles.ps1" -Recurse).Fullname

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
Pop-Location -StackName "WorkingPath"

'@
$PSPContentISE += $Content
    
#--------------------------------------------------#
# Multi Remote Management
#--------------------------------------------------#  
if($Features | Where{$_.Name -eq "Multi Remote Management"}){
   
    $RDPTemplate = $(Get-ChildItem -Path $PStemplates.Path -Filter "Default.rdp" -Recurse).FullName    
	$RDPConfig  = Join-Path -Path $PSconfigs.Path -ChildPath "Default.rdp"
    
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter "Default.rdp" -Recurse)){
    
        Write-Host "Copy default rdp config file to the config folder"        
		Copy-Item -Path $RDPTemplate -Destination $RDPConfig
	}   

    $WinSCPTemplate = $(Get-ChildItem -Path $PStemplates.Path -Filter "WinSCP.ini" -Recurse).FullName    
	$WinSCConfig  = Join-Path -Path $PSconfigs.Path -ChildPath "WinSCP.ini"
    
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter "WinSCP.ini" -Recurse)){
    
        Write-Host "Copy default rdp config file to the config folder"        
		Copy-Item -Path $WinSCPTemplate -Destination $WinSCConfig
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

Pop-Location -StackName "WorkingPath"

Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
Read-Host "Press Enter to exit"
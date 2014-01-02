$Metadata = @{
    Title = "Profile Installation"
    Filename = "Microsoft.PowerShell_profile.install.ps1"
    Description = ""
    Tags = "powershell, profile, installation"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-03-18"
    LastEditDate = "2014-01-02"
    Version = "7.1.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}


#--------------------------------------------------#
#  project init
#--------------------------------------------------#

# check compatiblity
if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}

# create PowerShell Profile
if (!(Test-Path $Profile)){

    # Create a profile
    Write-Host "Add a default profile script"
	New-Item -path $Profile -type file -force | Out-Null
}


#--------------------------------------------------#
#  global settings
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

# autoinclude functions
Get-childitem ($PSfunctions.Path) -Recurse | where{($_.Name.EndsWith("ps1")) -and (-not $_.PSIsContainer)} | foreach{. ($_.Fullname)}


#--------------------------------------------------#
#  Profile settings
#--------------------------------------------------#

# cast vars
$Features = @()
$Systemvariables = @()

# load configuration files
Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Profile.Filter -Recurse | %{
    [xml]$(get-content $_.FullName)} | %{
        $Features += $_.Content.Feature;$Systemvariables += $_.Content.Systemvariable}
     
        
#--------------------------------------------------#
#  Profile scripts
#--------------------------------------------------#
        
# cast vars
$PPContent = @()
$PPISEContent = @()

# Metadata

$PPContent += @'
    
$Metadata = @{
Title = "Powershell Profile"
Filename = "Microsoft.PowerShell_profile.ps1"
Description = ""
Tags = "powershell, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "http://janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2014-01-02"
Version = "7.1.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@


# Metadata ISE   
 
$PPISEContent += @'
    
$Metadata = @{
Title = "Powershell ISE Profile"
Filename = "Microsoft.PowerShellISE_profile.ps1"
Description = ""
Tags = "powershell, ise, profile"
Project = ""
Author = "Janik von Rotz"
AuthorContact = "http://janikvonrotz.ch"
CreateDate = "2013-04-22"
LastEditDate = "2014-01-02"
Version = "7.1.0"
License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@

#--------------------------------------------------#
# default features
#--------------------------------------------------#


$PPContent += $Content = @'
# main
. '
'@ + (Join-Path -Path $PSProfile.Path -ChildPath "Microsoft.PowerShell_profile.config.ps1") + "'`n"
$PPISEContent += $Content


# Autoinclude Functions

Write-Host "Add Autoinclude Functions to the profile script"
$PPContent += $Content = @'
# Autoinclude Functions
Get-childitem ($PSfunctions.Path) -Recurse | where{($_.Name.EndsWith("ps1")) -and (-not $_.PSIsContainer)} | foreach{. ($_.Fullname)}

'@
$PPISEContent += $Content


# Transcript Logging
	
Write-Host "Add Transcript Logging to the profile script"
$PPContent += @'
# Transcript Logging
Start-Transcript -path $PSlogs.SessionFile
Write-Host ""

'@

#--------------------------------------------------#
# functions
#--------------------------------------------------#
function Check-ProfileFeatureStatus{

	param(
		[string]
		$Name
	)
	
	if($Features | Where{($_.Name -eq $Name) -and ($_.Status -eq "Enabled")}){
	
		$true
	
	}elseif($Features | Where{($_.Name -eq $Name) -and ($_.Status -eq "Disabled")}){
	
		$false
	
	}else{
	
		throw "Could not find feature definition for: $Name"	
	}
}


#--------------------------------------------------#
# customizable features
#--------------------------------------------------#


# add system variables

if($SystemVariables -ne $Null){$SystemVariables | %{
        
        Write-Host "Adding path variable: $($_.Value)"
        
        $Path = Get-Path $_.Value
        
        if(Test-Path $Path){Add-PathVariable -Value $Path -Name $_.Name -Target $_.Target
            
        }else{Write-Error "Path: $Path doesn't exist. Not possible to add value to system variable: $($_.Name)"}
    }
}


# Enable Open Powershell here

if(Check-ProfileFeatureStatus "Enable Open Powershell here"){
    
    Write-Host "Adding 'Open PowerShell Here' to context menu "
	$Null = Enable-OpenPowerShellHere
		
}


# Get Quote Of The Day

if(Check-ProfileFeatureStatus "Get Quote Of The Day"){
    Write-Host "Add Get Quote Of The Day to the profile script"
	$PPContent += $Content = @'
# Get Quote Of The Day
Get-QuoteOfTheDay
Write-Host ""

'@
    $PPISEContent += $Content
}


# Git Update

if(Check-ProfileFeatureStatus "Git Update"){
   
    Update-PowerShellProfile
    
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.GitUpdate.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.GitUpdate.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.GitUpdate.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.GitUpdate.Name)
	}
    
    Update-ScheduledTask "Git Update"
}


# Log File Retention

if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Status -eq "Disabled") -and ($_.Run -match "asDailyJob")}){

    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.LogFileRetention.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.LogFileRetention.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.LogFileRetention.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.LogFileRetention.Name)
	}
    
    Update-ScheduledTask "Log File Retention"
}


# Log File Retention

if($Features | Where{($_.Name -contains "Log File Retention") -and ($_.Status -eq "Disabled") -and ($_.Run -match "withProfileScript")}){
                    
    Write-Host "Add Log File Retention to the profile script"
    $PPContent += $Content = @'
# Log File Retention
Delete-ObsoleteLogFiles

'@
    $PPISEContent += $Content
}


# Powershell Remoting

if(Check-ProfileFeatureStatus "Powershell Remoting"){
    
    Write-Host "Enabling Powershell Remoting"
	Enable-PSRemoting -Confirm:$false
	Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
	Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
	restart-Service WinRM -Confirm:$false
}


# Custom PowerShell Profile script

if(Check-ProfileFeatureStatus "Custom PowerShell Profile script"){

    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.CustomPPscript.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.CustomPPscript.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.CustomPPscript.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.CustomPPscript.Name)
	}
    
    Write-Host "Include Custom PowerShell Profile script"
	$PPContent += $(Get-Content (Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.CustomPPscript.Name -Recurse).Fullname) + "`n"
}


# Custom PowerShell Profile ISE script

if(Check-ProfileFeatureStatus "Custom PowerShell Profile ISE script"){

    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.CustomPPISEscript.Name -Recurse)){    
        Write-Host "Copy $($PStemplates.CustomPPISEscript.Name) file to the config folder"      
        Copy-Item -Path $PStemplates.CustomPPISEscript.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.CustomPPISEscript.Name)
	}
    
    Write-Host "Include Custom PowerShell Profile script"
	$PPISEContent += $Content = $(Get-Content (Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.CustomPPISEscript.Name -Recurse).Fullname) + "`n"
}


#--------------------------------------------------#
# feature selection end
#--------------------------------------------------#

$PPContent += $Content = @'
# main end
Set-Location $WorkingPath

'@
$PPISEContent += $Content

# Write content to PowerShell Profile script file
Write-Host "Creating PowerShell Profile Script"
Set-Content -Value $PPContent -Path $Profile

# Add ISE Profile Script
Write-Host "Creating PowerShell ISE Profile Script"
Set-Content -Value $PPISEContent -Path (Join-Path -Path (Split-Path $profile -Parent) -ChildPath "Microsoft.PowerShellISE_profile.ps1")

Set-Location $WorkingPath

Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
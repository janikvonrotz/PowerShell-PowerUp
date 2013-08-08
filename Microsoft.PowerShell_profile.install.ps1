$Metadata = @{
	Title = "Profile Installation"
	Filename = "Microsoft.PowerShell_profile.install.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-18"
	LastEditDate = "2013-06-12"
	Version = "5.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}else{

    #--------------------------------------------------#
    #  Settings
    #--------------------------------------------------#
    
    [string]$WorkingPath = Get-Location
    
    # resets
    $Features = @()
    $Systemvariables = @()
    $RegistryEntrys =@()
    
    # load global configurations
    .\Microsoft.PowerShell_profile.config.ps1

    #--------------------------------------------------#
    #  include modules
    #--------------------------------------------------#
    
	$env:PSModulePath += ";"+ ($PSmodules.Path)
	Import-Module Pscx
    	
	#--------------------------------------------------#
	# autoinclude functions
	#--------------------------------------------------#
    
    $IncludeFolders = @()
    $IncludeFolders += $PSfunctions.Path
    $IncludeFolders += get-childitem ($PSfunctions.Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
    foreach ($IncludeFolder in $IncludeFolders){
	    Set-Location $IncludeFolder
	    get-childitem $IncludeFolder | where{ ! $_.PSIsContainer} | foreach {. .\$_}
    }
	Set-Location $WorkingPath
    
	#--------------------------------------------------#
    # system settings
    #--------------------------------------------------#
    
    # Add module path to the system variables
    Write-Host ("Adding PSModulePath: " + $PSmodules.Path)
    Add-PathVariable -Value $PSmodules.Path -Name PSModulePath -Target Machine
    
	# load configuration files
    $ConfigFiles = Get-ChildItem -Path $PSconfigs.Path -Filter "*.profile.config.*" -Recurse
    
    # merge configurations files content
    foreach($ConfigFile in $ConfigFiles){
        Write-Host ("Loading configurations from " + $ConfigFile.Name)
        [xml]$Content  = Get-Content $ConfigFile.Fullname
        $Features += $Content.Content.Feature
        $Systemvariables += $Content.Content.Systemvariable
        $RegistryEntrys += $Content.Content.RegistryEntry
    }
      
    #--------------------------------------------------#
    # add registry keys
    #--------------------------------------------------#
    
    foreach ($RegistryEntry in $RegistryEntrys)
    {
		Write-Host ("Adding registry entry: " + $RegistryEntry.Name)
	    Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
    }

    #--------------------------------------------------#
    # add system variables
    #--------------------------------------------------#
    
    foreach ($SystemVariable in $SystemVariables){
        
        Write-Host ("Adding path variable: " + $SystemVariable.Value)
        
        if($SystemVariable.RelativePath -eq "true"){
        
            #Gets the static path from a relative path
            $StaticPath = Convert-Path -Path (Join-Path -Path $(Get-Location).Path -Childpath $SystemVariable.Value)

            Add-PathVariable -Value $StaticPath -Name $SystemVariable.Name -Target $SystemVariable.Target
            
        }else{            
            $StaticPath = Invoke-Expression ($Command = '"' + $SystemVariable.Value + '"')
            
            Add-PathVariable -Value $StaticPath -Name $SystemVariable.Name -Target $SystemVariable.Target
        }

    }

	
	
	#--------------------------------------------------#
	# Features
	#--------------------------------------------------#
    
    #resets
	$PSContent = ""
    $PSContentISE = ""
    $PSContentISEArray = ""
     
	#--------------------------------------------------#
	# Git Update Task
	#--------------------------------------------------#
	if($Features | Where-Object {$_.Name -eq 'Git Update Task'}){	
    			
		$PathToScript = Get-ChildItem -Path $PSconfigs.Path -Filter "Git-Update.ps1" -Recurse
		Add-SheduledTask -Title "Git Update Task" -Command "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Arguments $PathToScript.Fullname -WorkingDirectory $WorkingPath -XMLFilename "GitUpdateTask"
	}
    
	#--------------------------------------------------#
	# Powershell Remoting
	#--------------------------------------------------# 
	if($Features | Where-Object {$_.Name -eq "Powershell Remoting"}){
    
        Write-Host "Enabling Powershell Remoting"
		Enable-PSRemoting
		Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
		Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
		restart-Service WinRM		
	}

	#--------------------------------------------------#
	# Enable Open Powershell here
	#--------------------------------------------------#  
	if($Features | Where-Object {$_.Name -eq "Enable Open Powershell here"}){
    
        Write-Host "Adding 'Open PowerShell Here' to context menu "
		$Null = Enable-OpenPowerShellHere
		
	}
 
 	#--------------------------------------------------#
	# Path System Variable For App Subfolders
	#--------------------------------------------------#     
	if($Features | Where-Object {$_.Name -eq "Path System Variable For App Subfolders"}){
    
        $SystemFolders = @(Get-ChildItem $PSapps.Path -Force | Where {$_.PSIsContainer})
		$SystemFolders | %{
        
            Write-Host ("Adding path variable: " + $_.Name)
            Add-PathVariable -Value $_.Fullname -Name "Path" -Target "Machine"
        }
	}
    
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
	LastEditDate = "2013-06-12"
	Version = "4.0.0"
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
	LastEditDate = "2013-06-12"
	Version = "4.0.0"
	License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
    $PSContentISEArray += $PSContentISE

	# Main
	$PSContent += $PSContentISE = @'

#--------------------------------------------------#
# main
#--------------------------------------------------#
[string]$WorkingPath = Get-Location
$ProfilePath = Split-Path $MyInvocation.MyCommand.Definition -parent
Invoke-Expression ($ProfilePath + "\Microsoft.PowerShell_profile.config.ps1")

'@
    $PSContentISEArray += $PSContentISE
	
    #--------------------------------------------------#
	# Custom PowerShell CLI
	#--------------------------------------------------#  
	if($Features | Where-Object {$_.Name -eq "Custom PowerShell CLI"}){
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

    #--------------------------------------------------#
	# Autoinclude Functions
	#--------------------------------------------------#  
	if($Features | Where-Object {$_.Name -eq "Autoinclude Functions"}){
    Write-Host "Add Autoinclude Functions to the profile script"
	$PSContent += $PSContentISE = @'

#--------------------------------------------------#
# Autoinclude Functions
#--------------------------------------------------#
$IncludeFolders = @()
$IncludeFolders += $PSfunctions.Path
$IncludeFolders += get-childitem ($PSfunctions.Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
foreach ($IncludeFolder in $IncludeFolders){
	Set-Location $IncludeFolder
	get-childitem $IncludeFolder | where{ ! $_.PSIsContainer} | foreach {. .\$_}
}

'@	
}
	$PSContentISEArray += $PSContentISE
    
    #--------------------------------------------------#
	# Custom Aliases
	#--------------------------------------------------# 
	if($Features | Where-Object {$_.Name -eq "Custom Aliases"}){
    Write-Host "Add Custom Aliases to the profile script"
	$PSContent += $PSContentISE = @'

#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------#	
nal -Name rdp -Value "Connect-RDPSession"
nal -Name rps -Value "Connect-PSSession"
nal -Name http -Value "Connect-HttpSession"
nal -Name psssh -Value "Connect-SSHSession"
nal -Name psscp -Value "Connect-SCPSession"
nal -Name pssftp -Value "Connect-FTPSession"

'@
}
    $PSContentISEArray += $PSContentISE
	
    #--------------------------------------------------#
	# Transcript Logging
	#--------------------------------------------------# 
	if($Features | Where-Object {$_.Name -eq "Transcript Logging"}){
    Write-Host "Add Transcript Logging to the profile script"
	$PSContent += @'

#--------------------------------------------------#
# Transcript Logging
#--------------------------------------------------#	
Start-Transcript -path ($PSlogs.Path + "\PowerShell Session " + $(Get-LogStamp) + " " + $env:COMPUTERNAME  + "-" + $env:USERNAME  + ".txt")
Write-Host ""

'@
}

    #--------------------------------------------------#
	# Get Quote Of The Day
	#--------------------------------------------------# 
	if($Features | Where-Object {$_.Name -eq "Get Quote Of The Day"}){
    Write-Host "Add Get Quote Of The Day to the profile script"
	$PSContent += $PSContentISE = @'

#--------------------------------------------------#
# Get Quote Of The Day
#--------------------------------------------------#	
Get-QuoteOfTheDay
Write-Host ""

'@
}
    $PSContentISEArray += $PSContentISE
	
	# Main End
	$PSContent += $PSContentISE = @'

#--------------------------------------------------#
# main end
#--------------------------------------------------#
Set-Location $WorkingPath

'@
    $PSContentISEArray += $PSContentISE
    
    #--------------------------------------------------#
	# Multi Remote Management
	#--------------------------------------------------#  
    if($Features | Where-Object {$_.Name -eq "Multi Remote Management"}){
    			
        # RDP Default file
        $ContentDefaultRDP = @'
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
		$DefaultRDPFile  = $PSconfigs.Path + "\Default.rdp"
        if(!(test-path $DefaultRDPFile)){
            Write-Host "Adding Default RDP file to the config folder"
			Set-Content -Value $ContentDefaultRDP -Path ($DefaultRDPFile)			
		}
    }

	# Write content to script file
    Write-Host "Creating PowerShell Profile Script"
    Set-Content -Value $PSContent -Path $PSProfileScript.Name
    
    #--------------------------------------------------#
	# Add ISE Profile Script
	#--------------------------------------------------#
    if($Features | Where-Object {$_.Name -eq "Add ISE Profile Script"}){
        Write-Host "Creating PowerShell ISE Profile Script"
        Set-Content -Value $PSContentISEArray -Path $PSProfileISEScript.Name
    }
	
	#--------------------------------------------------#
	# Powershell Profile Link
	#--------------------------------------------------#
	# Create Powershell Profile
	if (!(Test-Path $Profile)){

        # Create a profile
        Write-Host "Add a default profile script"
		New-Item -path $Profile -type file -force

	}

	# Link Powershell Profile
	$SourcePath = Split-Path $profile -parent
	$ScriptName = $MyInvocation.MyCommand.Name

	if (!(Test-Path ($SourcePath + "\" + $ScriptName) -PathType Leaf))
	{
        Write-Host "Redirect Default PowerShell Profile script to custom PowerShell Profile script"
        
		# Rename default source
		Rename-Item $SourcePath ($SourcePath + "-Obsolete")
 
		# Create a shortcut to the existing powershell profile
		New-Symlink $SourcePath $WorkingPath
	}
	
	Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
	Read-Host "Press Enter to exit"

}
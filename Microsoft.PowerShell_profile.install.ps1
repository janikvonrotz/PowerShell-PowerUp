$Metadata = @{
	Title = "Profile Installation"
	Filename = "Microsoft.PowerShell_profile.install.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-18"
	LastEditDate = "2013-04-24"
	Version = "4.2.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}else{

    [string]$WorkingPath = Get-Location	
    $Features = @()
    
    #--------------------------------------------------#
    #  Settings
    #--------------------------------------------------#
    .\Microsoft.PowerShell_profile.config.ps1

    #--------------------------------------------------#
    #  Include Modules
    #--------------------------------------------------#
	$env:PSModulePath += ";"+ ($PSmodules.Path)
	Import-Module Pscx
    	
	#--------------------------------------------------#
	# Autoinclude Functions
	#--------------------------------------------------#
    #Include functions
    $IncludeFolders = @()
    $IncludeFolders += $PSfunctions.Path
    $IncludeFolders += get-childitem ($PSfunctions.Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
    foreach ($IncludeFolder in $IncludeFolders){
	    Set-Location $IncludeFolder
	    get-childitem $IncludeFolder | where{ ! $_.PSIsContainer} | foreach {. .\$_}
    }
	Set-Location $WorkingPath
    
	#--------------------------------------------------#
    # System Settings
    #--------------------------------------------------#
    # Add module path to the system variables
    Add-PathVariable -Value $PSmodules.Path -Name PSModulePath -Target Machine
	[string]$PSmodulePath = $PSmodules.Path
	Write-Warning "Added PSModulePath: $PSmodulePath"
    
    #Load configurations
    $ConfigFiles = Get-ConfigurationFilesContent -Path $PSconfigs.Path -SearchExpression "*.profile.config.*"
	
	
    foreach($ConfigFile in $ConfigFiles){
        
        $Config = $ConfigFile.Content.Configuration
        
		#--------------------------------------------------#
		# Add Registry Keys
		#--------------------------------------------------#
        foreach ($RegistryEntry in $Config.RegistryEntries.RegistryEntry)
        {
	        Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
            [string]$Name =  $RegistryEntry.Name
		    Write-Warning "Added registry entry: $Name "
        }

		#--------------------------------------------------#
		# Add System Variables
		#--------------------------------------------------#
        foreach ($SystemVariable in $Config.SystemVariables.SystemVariable)
        {
	        if($SystemVariable.RelativePath -eq "true")
	        {
                #Gets the static path from a relative path
		        $StaticPath = Convert-Path -Path (Join-Path -Path $(Get-Location).Path -Childpath $SystemVariable.Value)
                
		        Add-PathVariable -Value $StaticPath -Name $SystemVariable.Name -Target $SystemVariable.Target
	        }else{
				$StaticPath = Invoke-Expression ($Command = '"' + $SystemVariable.Value + '"')
		        Add-PathVariable -Value $StaticPath -Name $SystemVariable.Name -Target $SystemVariable.Target
	        }            [string]$Name =  $SystemVariable.Value
		    Write-Warning "Added path variable: $Name "
        }
        
        # Collect features
    	foreach($Feature in $Config.Features.Feature){
    		$Features += $Feature.Name
    	}
	}
	
	#--------------------------------------------------#
	# Features
	#--------------------------------------------------#
	$Content = ""
    $ContentISE = ""
    $ContentISEArray = ""
    
	# Git Update Task
	if($Features -contains "Git Update Task"){				
		$PathToScript = Get-ChildItem -Path $PSconfigs.Path -Filter "Git-Update.ps1" -Recurse
		Add-SheduledTask -Title "Git Update Task" -Command "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Arguments $PathToScript.Fullname -WorkingDirectory $WorkingPath -XMLFilename "GitUpdateTask.xml"
	}

	# Powershell Remoting
	if($Features -contains "Powershell Remoting"){
		Enable-PSRemoting
		Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
		Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
		restart-Service WinRM
		Write-Warning "Powershell Remoting enabled"
	}
	
	# Enable Open Powershell here
	if($Features -contains "Enable Open Powershell here"){
		$Null = Enable-OpenPowerShellHere
		Write-Warning "Added 'Open PowerShell Here' to context menu "
	}
    
	# Metadata
	$Content += @'
    
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

'@
    
    # Metadata ISE    
    $ContentISE += @'
    
$Metadata = @{
	Title = "Powershell ISE Profile"
	Filename = "Microsoft.PowerShellISE_profile.ps1"
	Description = ""
	Tags = "powershell, ise, profile"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-22"
	LastEditDate = "2013-04-22"
	Version = "3.1.0"
	License = "This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA."
}

'@
    $ContentISEArray += $ContentISE

	# Main
	$Content += $ContentISE = @'

#--------------------------------------------------#
# Main
#--------------------------------------------------#
[string]$WorkingPath = Get-Location
$ProfilePath = Split-Path $MyInvocation.MyCommand.Definition -parent
Invoke-Expression ($ProfilePath + "\Microsoft.PowerShell_profile.config.ps1")

'@
    $ContentISEArray += $ContentISE
	
	# Custom PowerShell CLI
	if($Features -contains "Custom PowerShell CLI"){
	$Content += @'

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
	Write-Warning "Added Custom PowerShell CLI to the profile script"
}

	# Autoinclude Functions
	if($Features -contains "Autoinclude Functions"){
	$Content += $ContentISE = @'

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
	Write-Warning "Added Autoinclude Functions to the profile script"
}
	$ContentISEArray += $ContentISE
    
	# Custom Aliases
	if($Features -contains "Custom Aliases"){
	$Content += $ContentISE = @'

#--------------------------------------------------#
# Custom Aliases
#--------------------------------------------------#	
nal -Name rdp -Value "Connect-RDPSession"
nal -Name rps -Value "Connect-PSSession"
nal -Name http -Value "Connect-HttpSession"
nal -Name psssh -Value "Connect-SSHSession"
nal -Name psscp -Value "Connect-SCPSession"

'@
	Write-Warning "Added Custom Aliases to the profile script"
}
    $ContentISEArray += $ContentISE
	
	# Transcript Logging
	if($Features -contains "Transcript Logging"){
	$Content += @'

#--------------------------------------------------#
# Transcript Logging
#--------------------------------------------------#	
Start-Transcript -path ($PSlogs.Path + "\PowerShell Session " + $(Get-LogStamp) + " " + $env:COMPUTERNAME  + "-" + $env:USERNAME  + ".txt")
Write-Host ""

'@
	Write-Warning "Added Transcript Logging to the profile script"
}

	# Custom Aliases
	if($Features -contains "Get Quote Of The Day"){
	$Content += $ContentISE = @'

#--------------------------------------------------#
# Get Quote Of The Day
#--------------------------------------------------#	
Get-QuoteOfTheDay
Write-Host ""

'@
	Write-Warning "Added Get Quote Of The Day to the profile script"
}
    $ContentISEArray += $ContentISE
	
	# Main End
	$Content += $ContentISE = @'

#--------------------------------------------------#
# Main End
#--------------------------------------------------#
Set-Location $WorkingPath

'@
    $ContentISEArray += $ContentISE
    
    # Multi Remote Management
    if($Features -contains "Multi Remote Management"){
    
        # # Remote config file
        # $ContentRemoteConfigXml = @'

# '@	
        # # Write content to config file
        # Set-Content -Value $ContentRemoteConfigXml -Path ($PSconfigs.Path + "\EXAMPLE.remote.config.xml")
        # Write-Warning "Added Remote config file to the config folder"
			
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
			Set-Content -Value $ContentDefaultRDP -Path ($DefaultRDPFile)
			Write-Warning "Added Default RDP file to the config folder"
		}
    }

	# Write content to script file
    Set-Content -Value $Content -Path $PSProfileScript.Name
        
    if($Features -contains "Add ISE Profile Script"){
        Set-Content -Value $ContentISEArray -Path $PSProfileISEScript.Name
		Write-Warning "Added ISE Profile Script"
    }
    
    

	#--------------------------------------------------#
	# Write PowerShell Profile script
	#--------------------------------------------------#
	
	#--------------------------------------------------#
	# Powershell Profile Link
	#--------------------------------------------------#

	# Create Powershell Profile
	if (!(Test-Path $Profile)){

		  # Create a profile
		New-Item -path $Profile -type file -force
		Write-Warning "New profile script"
	}

	# Link Powershell Profile
	$SourcePath = Split-Path $profile -parent
	$ScriptName = $MyInvocation.MyCommand.Name

	if (!(Test-Path ($SourcePath + "\" + $ScriptName) -PathType Leaf))
	{
		# Rename default source
		Rename-Item $SourcePath ($SourcePath + "-Obsolete")
 
		# Create a shortcut to the existing powershell profile
		New-Symlink $SourcePath $WorkingPath
		Write-Warning "Redirect for PowerShell profile path added"
	}
	
	Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
	Read-Host "Press Enter to exit"

}
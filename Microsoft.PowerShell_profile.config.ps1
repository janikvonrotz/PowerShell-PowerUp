<#
$Metadata = @{
	Title = "Microsoft PowerShell profile configuration"mi	
	Filename = "Microsoft.PowerShell_profile.config.ps1"
	Description = ""
	Tags = "microsoft, powershell, configuration, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-11"
	LastEditDate = "2013-10-17"
	Version = "6.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

$global:WorkingPath = (Get-Location).Path

$global:PSProfile = New-Object PSObject -Property @{
	Path = Split-Path $MyInvocation.MyCommand.Definition -Parent
}
	
$global:PSfunctions = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "functions"
}

$global:PSlogs = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "logs"

    EventLogName = "PowerShell Profile"
    EventLogSources = @("PowerShell Profile", "Scheduled Task")
    ErrorEventId = 666
    InformationEventId = 0
    WarningEventId = 333
	SessionFile = (Join-Path -Path (Join-Path -Path $PSProfile.Path -ChildPath "logs") -ChildPath ("PowerShell Session " + $((get-date -format o) -replace ":","-") + " " + $env:COMPUTERNAME  + "-" + $env:USERNAME  + ".txt"))
}

$global:PSconfigs = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "configs"
    
    Profile = New-Object PSObject -Property @{
        Filter = "*.profile.config.xml"
    }
    Remote = New-Object PSObject -Property @{
        Filter = "*.remote.config.*"
    }
    Mail = New-Object PSObject -Property @{
        Filter = "*.mail.config.xml";
        ErrorClass = "ErrorReport"
    }
    Task = New-Object PSObject -Property @{
        Filter = "*.task.config.xml";
    }
}	

$global:PSscripts = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "scripts"
	
	Install = Get-ChildItem -Path (Split-Path $MyInvocation.MyCommand.Definition -Parent) -Filter "Microsoft.PowerShell_profile.install.ps1" -Recurse
}

$global:PSapps = New-Object PSObject -Property @{    
    PowerShell = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
}

$global:PStemplates = New-Object PSObject -Property @{
    Path = Join-Path -Path $PSProfile.Path -ChildPath "templates"
    
    Mail = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.mail.config.xml" -Recurse
    Profile = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.profile.config.xml" -Recurse
    Remote = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.remote.config.xml" -Recurse
    GitUpdate = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Git-Update.task.config.xml" -Recurse
    LogFileRetention = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Delete-ObsoleteLogFiles.task.config.xml" -Recurse
    RDP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Default.rdp" -Recurse
    WinSCP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "WinSCP.ini" -Recurse
	CustomPPscript = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Custom PowerShell Profile.script.config.ps1" -Recurse
    CustomPPISEscript = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Custom PowerShell Profile ISE.script.config.ps1" -Recurse
} 
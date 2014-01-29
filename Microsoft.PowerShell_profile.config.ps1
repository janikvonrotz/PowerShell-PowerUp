<#
$Metadata = @{
	Title = "Microsoft PowerShell profile configuration"	
	Filename = "Microsoft.PowerShell_profile.config.ps1"
	Description = ""
	Tags = "microsoft, powershell, configuration, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-11"
	LastEditDate = "2013-10-17"
	Version = "7.0.0"
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
	
	GitSource = "https://github.com/janikvonrotz/PowerShell-PowerUp.git"
	
	Install = Get-ChildItem -Path (Split-Path $MyInvocation.MyCommand.Definition -Parent) -Filter "Microsoft.PowerShell_profile.install.ps1" -Recurse
}

$global:PSbin = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "bin"
}
	
$global:PSfunctions = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "functions"
    
    FormatData = New-Object PSObject -Property @{
        Path = Join-Path -Path $PSProfile.Path -ChildPath "functions/FormatData"
        Filter = "*.format.ps1xml"
    }
}

$global:PSlib = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "lib"
}

$global:PSlogs = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "logs"

	SessionFile = (Join-Path -Path (Join-Path -Path $PSProfile.Path -ChildPath "logs") -ChildPath ("PowerShell Session " + $((get-date -format o) -replace ":","-") + " " + $env:COMPUTERNAME  + "-" + $env:USERNAME  + ".txt"))
}

$global:PSconfigs = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "configs"
    
	File = New-Object PSObject -Property @{
        Filter = "*.config.xml"
    }	
    App = New-Object PSObject -Property @{
        Filter = "*.app.config.xml"
        DataFile = "PackageManager.config.xml"
    }	
	Credential = New-Object PSObject -Property @{
        Filter = "*.credential.config.xml"
    }
	EventLog = New-Object PSObject -Property @{
        Filter = "*.eventlog.config.xml"
    }
    Mail = New-Object PSObject -Property @{
        Filter = "*.mail.config.xml"
        ErrorClass = "ErrorReport"
    }
    Profile = New-Object PSObject -Property @{
        Filter = "*.profile.config.xml"
    }
	Script = New-Object PSObject -Property @{
        Filter = "*.script.config.xml"
    }
	ScriptShortcut = New-Object PSObject -Property @{
		DataFile = "ScriptShortcut.tmp.xml"
    }
    Server = New-Object PSObject -Property @{
        Filter = "*.server.config.xml"
    }
    Task = New-Object PSObject -Property @{
        Filter = "*.task.config.xml"
    }
    TrueCryptContainer = New-Object PSObject -Property @{
        Filter = "*.truecryptcontainer.config.xml"
        DataFile = "TrueCrypt.tmp.xml"
    }
	User = New-Object PSObject -Property @{
        Filter = "*.user.config.xml"
    }
}	

$global:PSscripts = New-Object PSObject -Property @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "scripts"
    Extensions = ".ps1",".ps2",".ps3",".psm"
}

$global:PSapps = New-Object PSObject -Property @{    
    PowerShell = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
}

$global:PStemplates = New-Object PSObject -Property @{
    Path = Join-Path -Path $PSProfile.Path -ChildPath "templates"
    	
    GitUpdate = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Git-Update.task.config.xml" -Recurse
    LogFileRetention = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Delete-ObsoleteLogFiles.task.config.xml" -Recurse
    RDP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Default.rdp" -Recurse
    WinSCP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "WinSCP.ini" -Recurse
	CustomPPscript = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Custom PowerShell Profile.script.config.ps1" -Recurse
    CustomPPISEscript = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Custom PowerShell Profile ISE.script.config.ps1" -Recurse
} 
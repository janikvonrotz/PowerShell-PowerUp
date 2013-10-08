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
	LastEditDate = "2013-10-08"
	Version = "5.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

$global:PSProfile = @{
	Path = Split-Path $MyInvocation.MyCommand.Definition -Parent
}
	
$global:PSfunctions = @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "functions"
}

$global:PSlogs = @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "logs"
}

$global:PSconfigs = @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "configs";
    
    Profile = @{
        Filter = "*.profile.config.xml"
    };
    Remote = @{
        Filter = "*.remote.config.*"
    };
    Mail = @{
        Filter = "*.mail.config.xml";
        ErrorClass = "ErrorReport"
    };
    Task = @{
        Filter = "*.task.config.xml";
    }
}	

$global:PSscripts = @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "scripts";
}

$global:PSapps = @{
	Path = Join-Path -Path $PSProfile.Path -ChildPath "apps"
    
    PowerShell = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
}

$global:PStemplates = @{
    Path = Join-Path -Path $PSProfile.Path -ChildPath "templates";
    
    Mail = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.mail.config.xml" -Recurse;
    Profile = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.profile.config.xml" -Recurse;
    Remote = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "EXAMPLE.remote.config.xml" -Recurse;
    GitUpdate = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Git-Update.task.config.xml" -Recurse;
    LogFileRetention = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Delete-ObsoleteLogFiles.task.config.xml" -Recurse
    RDP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "Default.rdp" -Recurse;
    WinSCP = Get-ChildItem -Path (Join-Path -Path $PSProfile.Path -ChildPath "templates") -Filter "WinSCP.ini" -Recurse
} 
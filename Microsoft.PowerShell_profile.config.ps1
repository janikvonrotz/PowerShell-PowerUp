$Metadata = @{
	Title = "Microsoft PowerShell profile configuration"
	Filename = "Microsoft.PowerShell_profile.config.ps1"
	Description = ""
	Tags = "microsoft, powershell, configuration, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-11"
	LastEditDate = "2013-09-13"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

$global:PSProfilePath = Split-Path $MyInvocation.MyCommand.Definition -Parent
	
$global:PSfunctions = @{
	Path = Convert-Path($PSProfilePath + "\functions")
}

$global:PSlogs = @{
	Path = Convert-Path($PSProfilePath + "\logs")
}

$global:PSconfigs = @{
	Path = Convert-Path($PSProfilePath + "\configs")
}	

$global:PSscripts = @{
	Path = Convert-Path($PSProfilePath + "\scripts")
}

$global:PSapps = @{
	Path = Convert-Path($PSProfilePath + "\apps")
}

$global:PSscripts = @{
	Path = Convert-Path($PSProfilePath + "\scripts")
}

$global:PStemplates = @{
    Path = Convert-Path($PSProfilePath + "\templates");
    Mail = "EXAMPLE.mail.config.xml";
    Profile = "EXAMPLE.profile.config.xml";
    Remote = "EXAMPLE.remote.config.xml";
    Task = "EXAMPLE.task.config.xml";
    RDP = "Default.rdp";
    WinSCP = "WinSCP.ini"
} 

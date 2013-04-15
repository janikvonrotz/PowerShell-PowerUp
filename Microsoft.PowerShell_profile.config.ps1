$Metadata = @{
	Title = "Microsoft PowerShell profile configuration"
	Filename = "Microsoft.PowerShell_profile.config.ps1"
	Description = ""
	Tags = "microsoft, powershell, configuration, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-11"
	LastEditDate = "2013-04-11"
	Version = "0.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

[string]$ProfilePath = Split-Path $MyInvocation.MyCommand.Definition -Parent

$PSConfig = @{
	
	functions = @{
		Path = Convert-Path($ProfilePath + "\functions")
	}
	
	logs = @{
		Path = Convert-Path($ProfilePath + "\logs")
	}
	
	modules = @{
		Path = Convert-Path($ProfilePath + "\modules")
	}

	configs = @{
		Path = Convert-Path($ProfilePath + "\configs")
	}	
	
	scripts = @{
		Path = Convert-Path($ProfilePath + "\scripts")
	}
}

return $PSConfig
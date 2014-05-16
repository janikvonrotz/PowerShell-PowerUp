<#
$Metadata = @{
	Title = "Uninstall PowerShell PowerUp App"
	Filename = "Uninstall-PPApp.ps1"
	Description = ""
	Tags = "powershell, profile, install, apps"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-05-16"
	LastEditDate = "20114-05-16"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Uninstall-PPApp{

<#
.SYNOPSIS
    Install PowerShell PowerUp apps.

.DESCRIPTION
	Install PowerShell PowerUp apps.

.PARAMETER  Name
	Name and version sperated by # of the app.

.PARAMETER  Force
	Force the installation.
    
.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent#2.0.9", "SQL Server Maintenance Solution" -Force -Update

.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent"
    
#>

	param(
        [Parameter(Mandatory=$true)]
		[String[]]
		$Name,
                
        [switch]
        $Force,
        
        [switch]
        $IgnoreDependencies
	)
    
    Install-PPApp -Name $Name -Force:$Force -IgnoreDependencies:$IgnoreDependencies -Uninstall
}
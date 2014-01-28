<#
$Metadata = @{
	Title = "Get PowerShell Profile Configuration"
	Filename = "Get-PPConfiguration.ps1"
	Description = ""
	Tags = "powershell, profile, configuration, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-15"
	LastEditDate = "2014-01-08"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-PPConfiguration{

<#
.SYNOPSIS
	Returns the content of PowerShell Profile configuration files.

.DESCRIPTION
	Returns the content of PowerShell Profile configuration files.

.PARAMETER  Path
	Path to the config folder, deault is $PSconfigs.Path.

.PARAMETER  Filter
	Filter for the config filename. Default is $PSconfigs.File.Filter.

.EXAMPLE
	PS C:\> Get-PPConfiguration -Filter $PSconfigs.Mail.Filter
#>

	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Filter = $PSconfigs.File.Filter,
		
		[Parameter(Mandatory=$false)]
		$Path = $PSconfigs.Path
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	Get-ChildItem -Path $Path -Filter $Filter -Recurse | %{[xml]$(get-content $_.FullName)}
}
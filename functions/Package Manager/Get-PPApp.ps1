<#
$Metadata = @{
	Title = "Get PowerShell Profile App"
	Filename = "Get-PPApp.ps1"
	Description = ""
	Tags = "powershell, profile, get, apps"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-25"
	LastEditDate = "2013-10-25"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-PPApp{

<#
.SYNOPSIS
    Get available PowerShell Profile apps.

.DESCRIPTION
	Get available PowerShell Profile apps.

.PARAMETER  Name
	The description of the ParameterA parameter.
    
.EXAMPLE
	PS C:\> Get-PPApp

#>

	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Name,
        
        [switch]
        $Installed
	)
    
    if($Name){
        Get-PPConfiguration -Filter $PSconfigs.Install.Filter -Path $PSlib.Path | %{$_.Content.Package | where{$_.Name -match $Name}}
    }else{
        Get-PPConfiguration $PSconfigs.Install.Filter -Path $PSlib.Path | %{$_.Content.Package}
    }
}

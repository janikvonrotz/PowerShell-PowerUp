<#
$Metadata = @{
	Title = "Install PowerShell Profile App"
	Filename = "Install-PPApp.ps1"
	Description = ""
	Tags = "powershell, profile, install, apps"
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

function Install-PPApp{

<#
.SYNOPSIS
    Install PowerShell Profile apps.

.DESCRIPTION
	Install PowerShell Profile apps.

.PARAMETER  Name
	The description of the ParameterA parameter.

.PARAMETER  Version
	The description of the ParameterB parameter.

.PARAMETER  Version
	The description of the ParameterB parameter.

.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent", "SQL Server Maintenance Solution" -Version "2.0.9"

#>

	param(
        [Parameter(Mandatory=$true)]
		[String[]]
		$Name,
        
        [Parameter(Mandatory=$false)]
		[String[]]
        $Version
	)
    
    $NameAndVersion = $Name | %{
        $Index = [array]::indexof($Name,$_)
        if($Version){
            if($Version[$Index] -ne $null){
                $ThisVersion = $Version[$Index]
            }else{
                $ThisVersion = "*"
            }
        }else{
            $ThisVersion = "*"
        }
        $_ | select @{L="Name";E={$_}}, @{L="Version";E={$ThisVersion}}
    } 
    
    
    $NameAndVersion | %{
        $Version = $_.Version;
        Get-PPApp $_.Name | 
        sort Version |
        where{($_.Version -like $Version)} | 
        select -First 1} | %{
        
            Write-Host "Installing $($_.Name)"
            iex "'$((Get-ChildItem -Path $PSscripts.Path -Filter $_.InstallScript -Recurse | select -First 1).FullName)'"            
    }
    
}
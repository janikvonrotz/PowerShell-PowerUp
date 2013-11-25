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
	PS C:\> Install-PPApp "Zabbix Agent#2.0.9", "SQL Server Maintenance Solution"

#>

	param(
        [Parameter(Mandatory=$true)]
		[String[]]
		$Name,
        
        [Parameter(Mandatory=$false)]
		[String[]]
        $Version,
        
        [switch]
        $Force
	)
    
    $NameAndVersion = $Name | %{
            
        $Version = $_.split("#")[1]
        if(-not $Version){$Version = "*"}
        
        @{
            Name = $_.split("#")[0]
            Version = $Version            
        }
    } 
    
    
    $NameAndVersion | %{
        $Version = $_.Version
        Get-PPApp $_.Name | 
        sort Version |
        where{($_.Version -like $Version)} | 
        select -First 1
    } | %{
        
        # add parameter option force
        
        # check if already installed
        
        Write-Host "Installing Dependencies for $($_.Name)"
        
        if($_.Script){
            Write-Host "Installing $($_.Name) Version $($_.Version)"
            $ScriptPath = $((Get-ChildItem -Path $PSlib.Path -Filter $_.Script -Recurse | select -First 1).FullName)
            $AppPath = "`"$(Split-Path $ScriptPath -Parent)`""
            iex "& `"$ScriptPath`" -Version $($_.Version) -Path $AppPath"
        }
        
        #Update Package manager config           
    }    
}
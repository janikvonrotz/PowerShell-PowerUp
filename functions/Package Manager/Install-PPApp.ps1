<#
$Metadata = @{
	Title = "Install PowerShell PowerUp App"
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
    Install PowerShell PowerUp apps.

.DESCRIPTION
	Install PowerShell PowerUp apps.

.PARAMETER  Name
	The description of the ParameterA parameter.

.PARAMETER  Version
	The description of the ParameterB parameter.

.PARAMETER  Force
	Force the installation.

.PARAMETER  Update
	Update the package
    
.PARAMETER  Uninstall
	Force the installation.
    
.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent#2.0.9", "SQL Server Maintenance Solution" -Force -Update

.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent" -Uninstall
    
#>

	param(
        [Parameter(Mandatory=$true)]
		[String[]]
		$Name,
        
        [Parameter(Mandatory=$false)]
		[String[]]
        $Version,
        
        [switch]
        $Force,
        
        [switch]
        $Update,
        
        [switch]
        $Uninstall
	)
    
    $NameAndVersion = $Name | %{
            
        $Version = $_.split("#")[1]
        if(-not $Version){$Version = "*"}
        
        @{
            Name = $_.split("#")[0]
            Version = $Version            
        }
    } 
    
    $AppDataFile = Get-PPConfiguration -Filter $PSconfigs.App.DataFile -Path $PSconfigs.Path
    $InstalledApps = $AppDataFile | %{$_.Content.App}
    
    $NameAndVersion | %{
        $Version = $_.Version
        Get-PPApp $_.Name | 
        sort Version |
        where{($_.Version -like $Version)} | 
        select -First 1
    } | %{
        
        $Name = $_.Name
        $Version = $_.Version
               
        # check if already installed
        $InstalledApp = $InstalledApps | where{($_.Name -eq $Name) -and ($_.Version -eq $Version)}
        
        if(($InstalledApp -and -not $Force) -or ($InstalledApp -and -not $Update)){
        
            Write-Host "The Package: $Name is already installed, use the force parameter to reinstall, the update parameter to install a newer version or the uninstall parameter to remove this package"

        }elseif(($InstalledApp -and $Force) -or -not ($InstalledApp -and $Force)){        
        
            Write-Host "Installing Dependencies for $($_.Name)"
            
            if($_.Script){
            
                Write-Host "Installing $($_.Name) Version $($_.Version)"
                $ScriptPath = $((Get-ChildItem -Path $PSlib.Path -Filter $_.Script -Recurse | select -First 1).FullName)
                $Path = "$((Get-Location).Path)\"
                Invoke-Expression "& `"$ScriptPath`" -Version $($_.Version) -Path $Path -Force:`$Force -Update:`$Update -Uninstall:`$Uninstall"
            }
        
            # Update Package manager config
        }          
    }    
}
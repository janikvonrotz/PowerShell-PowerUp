<#
$Metadata = @{
	Title = "Get PowerShell PowerUp App"
	Filename = "Get-PPApp.ps1"
	Description = ""
	Tags = "powershell, profile, get, apps"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-25"
	LastEditDate = "20114-04-07"
	Url = ""
	Version = "1.1.0"
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
    Get available PowerShell PowerUp apps.

.DESCRIPTION
	Get available PowerShell PowerUp apps.

.PARAMETER Name
	Name of an app.
 
.PARAMETER Installed
	Only show globally installed apps.
    
.PARAMETER CurrentInstalled
	Only show apps that are installed in the current path.   
    
.EXAMPLE
	PS C:\> Get-PPApp

#>

	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Name,
        
        [switch]
        $Installed,
        
        [switch]
        $CurrentInstalled
	)
    
    # set default variables
    $CurrentLocation = (Get-Location).Path
    
    # get package manager configuations
    
    # config for current folder
    $CurrentAppDataFile = Join-Path $CurrentLocation $PSconfigs.App.DataFile
    
    # global config
    $GlobalAppDataFile = (Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.App.DataFile -Recurse).Fullname
    
    # get global configurations
    $InstalledApps = Get-PPConfiguration -Path $GlobalAppDataFile | %{$_.Content.App}
    
    # get apps installed in current folder    
    if(Test-Path $CurrentAppDataFile){
        $CurrentInstalledApps = Get-PPConfiguration -Path $CurrentAppDataFile | ForEach-Object{$_.Content.App}
    }    
        
    $(if($Name){
    
        Get-PPConfiguration -Filter $PSconfigs.App.Filter -Path $PSlib.Path | %{$_.Content.App | where{$_.Name -match $Name}}
        
    }else{
    
        Get-PPConfiguration $PSconfigs.App.Filter -Path $PSlib.Path | %{$_.Content.App}
        
    }) | %{
    
        if($Installed){
                
            $Name = $_.Name
            $Version = $_.Version
            
            $InstalledApps | where{($_.Name -eq $Name) -and ($_.Version -eq $Version)}
                  
        
        }elseif($CurrentInstalled){
        
            $Name = $_.Name
            $Version = $_.Version
            
            $CurrentInstalledApps | where{($_.Name -eq $Name) -and ($_.Version -eq $Version)}
        
        }else{
        
            $_
        }
    }
}
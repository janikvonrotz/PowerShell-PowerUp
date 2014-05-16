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
	LastEditDate = "20114-05-16"
	Url = ""
	Version = "2.0.0"
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
	Name and version sperated by # of the app.

.PARAMETER  Force
	Force the installation.
    
.PARAMETER  Uninstall
	Uninstall the app.
    
.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent#2.0.9", "SQL Server Maintenance Solution" -Force -Update

.EXAMPLE
	PS C:\> Install-PPApp "Zabbix Agent" -Uninstall
    
#>

	param(
        [Parameter(Mandatory=$false)]
		[String[]]
		$Name,
                
        [switch]
        $Force,
        
        [switch]
        $IgnoreDependencies,
                
        [switch]
        $Uninstall
	)
    
    # set default variables
    $CurrentLocation = (Get-Location).Path
    $AppData = @()	
    
    # get package manager configuations
    
    # config for current folder
    $CurrentAppDataFile = Join-Path $CurrentLocation $PSconfigs.App.DataFile
    
    # global config
    $GlobalAppDataFile = (Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.App.DataFile -Recurse).Fullname
    
    # create global config if not exits
    if(-not $GlobalAppDataFile){
        Copy-PPConfigurationFile -Name $PSconfigs.App.DataFile
        $GlobalAppDataFile = (Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.App.DataFile -Recurse).Fullname
    }
    
    # get global configurations
    $AppData += Get-PPConfiguration -Filter $PSconfigs.App.DataFile | ForEach-Object{$_.Content.App}
    
    # add current configurations to global
    if(Test-Path $CurrentAppDataFile){
        $CurrentInstalledApps = Get-PPConfiguration -Path $CurrentAppDataFile | ForEach-Object{$_.Content.App}
        $AppData += $CurrentInstalledApps
    }
    
    # extract the version and name of the app to install from the name parameter
    if($Name){
    
        $NameAndVersions = $Name | ForEach-Object{
                
            $Version = $_.split("#")[1]
            if(-not $Version){$Version = "*"}
            
            @{
                Name = $_.split("#")[0]
                Version = $Version            
            }
        }
    # otherwhise check the current config for apps to install
    }elseif($CurrentInstalledApps){
    
        $NameAndVersions = $CurrentInstalledApps | select Name, Version
    }
    
    # get existing apps
        
    $NameAndVersions | ForEach-Object{
    
        $Version = $_.Version
        Get-PPApp $_.Name | 
        sort Version -Descending |
        where{$_.Version -like $Version} |
        select -First 1
        
    } | ForEach-Object{
        
        # name of the package to install
        $Name = $_.Name
        
        # version to install (can be specific or latest)
        [Version]$Version = $_.Version
                
        # array of options
        $Options = $_.Option
        
        # reset values
        $AllowMultipleVersion = $false
                               
        # check if already installed
        
        # entry with appdata
        $AppEntry = $AppData | where{$_.Name -eq $Name}
                
        # entry with the same version
        $InstalledApp = $AppEntry | where{$_.Version -eq $Version}
        
        if($Uninstall -and -not $InstalledApp){
        
            $InstalledApp = $null
        
        }elseif(-not $InstalledApp){
        
            $InstalledApp = $AppData | where{$_.Name -eq $Name}
        }
        
        # get installed app if multiple versions is enabled
        switch($Options){
            "AllowMultipleVersions" {$InstalledApp = $null}
            "AllowMultipleMajorVersions" {
              
                $InstalledApp = $AppEntry | where{([Version]$_.Version).Major -eq $Version.Major}
                $AllowMultipleVersion = $true               
            }
            "AllowMultipleMinorVersions" {
                
                $InstalledApp = $AppEntry | where{([Version]$_.Version).Major -eq $Version.Major -and ([Version]$_.Version).Minor -eq $Version.Minor}
                $AllowMultipleVersion = $true 
            }
            "AllowMultipleBuildVersions" {
            
                $InstalledApp = $AppEntry | where{([Version]$_.Version).Major -eq $Version.Major -and ([Version]$_.Version).Minor -eq $Version.Minor -and ([Version]$_.Version).Build -eq $Version.Build}
                $AllowMultipleVersion = $true 
            }
            "AllowMultipleRevisionVersions" {
            
                $InstalledApp = $null
            }
        }
        
        # if app is already installed don't install
        # without force or uinstall parameter don't instal 
        if((-not $InstalledApp -and $Uninstall) -or ($InstalledApp.Status -eq "AppUninstalled" -and $Uninstall) -or ((([Version]$InstalledApp.Version -eq $Version) -or ([Version]$InstalledApp.Version -gt $Version)) -and -not ($Force -or $Uninstall) -and ($InstalledApp.Status -ne "AppUninstalled"))){
            if(-not $InstalledApp -and $Uninstall){
                Write-Warning "The Package: $Name is not installed"
            }elseif($Uninstall){
                Write-Warning "The Package: $Name is already uninstalled"
            }else{
                Write-Warning "The Package: $Name is already installed, use the force parameter to reinstall package, to downgrade it, or the uninstall parameter to remove this package"
            }
        # install the app
        }elseif(($InstalledApp -and $Force) -or -not ($InstalledApp -and $Force)){        
        
            # default settings
            $ScriptPath = $((Get-ChildItem -Path $PSlib.Path -Filter $_.Script -Recurse | select -First 1).FullName)
            $Path = "$($CurrentLocation)\"
                   
            if(-not $Uninstall -and -not $IgnoreDependencies){
            
                $_.Dependency | where{$_} | ForEach-Object{                    
                    
                    Write-Host "Installing Dependencies for $Name ..."
                    Install-PPApp -Name $(if($_.Version){"$($_.Name)#$($_.Version)"}else{$_.Name}) -Force:$Force
                    # Start-Process -FilePath (Get-Path $PSapps.PowerShell) -ArgumentList  "`"& {Install-PPApp -Name $(if($_.Version){"$($_.Name)#$($_.Version)"}else{$_.Name})$(if($Force){" -Force"})}`"" -Wait -NoNewWindow                    
                }
            } 
                       
            # check if this installation is an update 
            if($Uninstall){
            
                 Write-Host "Uninstalling $($_.Name) Version $($_.Version) ..."
            
            # check if version is going to change
            }elseif($InstalledApp -and ([Version]$InstalledApp.Version -ne $Version) -and ($InstalledApp.Status -ne "AppUninstalled")){
                
                # update the app
                if([Version]$InstalledApp.Version -lt $Version){
            
                    Write-Host "Updating $($_.Name) from Version $($AppEntry.Version) to Version $($_.Version)..."
                    $Update = $InstalledApp
                
                # downgrade the app
                }elseif([Version]$InstalledApp.Version -gt $Version){
                
                    Write-Host "Downgrading $($_.Name) from Version $($AppEntry.Version) to Version $($_.Version)..."
                    $Downgrade = $InstalledApp
                
                }
            
            # version is the same, reinstall
            }elseif($AppEntry -and $InstalledApp -and ($InstalledApp.Status -ne "AppUninstalled")){   
            
                Write-Host "Reinstalling $($_.Name) Version $($_.Version) ..."
            
            }else{                            

                Write-Host "Installing $($_.Name) Version $($_.Version) ..."
            }           
            
            $Config = Invoke-Expression "& `"$ScriptPath`" -Version $($_.Version) -Path $Path -Force:`$Force -Update:`$Update -Downgrade:`$Downgrade -Uninstall:`$Uninstall"                    
            
            if($Options -contains "UseLocalConfig"){
            
                # save to current config
                if(-not (Test-Path $CurrentAppDataFile)){
                    Copy-PPConfigurationFile -Name $PSconfigs.App.DataFile -Destination $CurrentLocation
                }
                $Xml = [xml](Get-Content (Join-Path $CurrentLocation $PSconfigs.App.DataFile))
                $AppDataFile = $CurrentAppDataFile                
                
            }else{
            
                # load package manager config
                $Xml = [xml](Get-Content $GlobalAppDataFile)   
                $AppDataFile = $GlobalAppDataFile    
            }
            
            # installation resulted in an error
            if($Config.Result -eq "Error"){
                  
                Write-Error "Installion of $($_.Name) completed unsuccessfully."           
            }   
                    
            # app installation didn't matched the conditions
            if($Config.Result -eq "ConditionExclusion"){
                
                Write-Error "Conditions exclution for $($_.Name) matched: $($Config.ConditionExclusion)"
            }  
              
            # app has been downgraded
            if($Config.Result -eq "AppDowngraded"){
            
                Write-Host "Downgrade of $($_.Name) to Version $($_.Version) completed successfully."
            
                $Element = Select-Xml -Xml $xml -XPath "//Content/App"| where{$_.Node.Name -eq $Name -and ($_.Node.Version -eq $InstalledApp.Version -or -not $InstalledApp)}
                $Element.Node.Status = $Config.Result
                $Element.Node.Version = $_.Version            
            }
                       
            # app has been update
            if($Config.Result -eq "AppUpdated"){
            
                Write-Host "Update of $($_.Name) to Version $($_.Version) completed successfully."
            
                $Element = Select-Xml -Xml $xml -XPath "//Content/App"| where{$_.Node.Name -eq $Name -and ($_.Node.Version -eq $InstalledApp.Version -or -not $InstalledApp)}
                $Element.Node.Status = $Config.Result
                $Element.Node.Version = $_.Version            
            }
            
            # app has been reinstalled
            if($InstalledApp -and $Config.Result -eq "AppInstalled"){
            
                Write-Host "Reinstallation of $($_.Name) completed successfully."     
                                
                $Element = Select-Xml -Xml $xml -XPath "//Content/App"| where{$_.Node.Name -eq $Name -and ($_.Node.Version -eq $InstalledApp.Version -or -not $InstalledApp)}
                $Element.Node.Status = $Config.Result
                $Element.Node.Version = $_.Version
            }
            
            # first installation of an app
            if($Config.Result -eq "AppInstalled" -and -not $InstalledApp){
            
                Write-Host "Installation of $($_.Name) completed successfully."
                
                $Element = $Xml.CreateElement("App")
                $Element.SetAttribute("Name",$_.Name)
                $Element.SetAttribute("Version",$_.Version)
                $Element.SetAttribute("Status", $Config.Result)
                $Content = Select-Xml -Xml $Xml -XPath "//Content"
                $Null = $Content.Node.AppendChild($Element)
                
            }
            
            # app has been uninstalled
            if($Config.Result -eq "AppUninstalled"){
            
                Write-Host "Uninstallaton of $($_.Name) completed successfully."
            
                $Element = Select-Xml -Xml $xml -XPath "//Content/App"| where{$_.Node.Name -eq $Name -and ($_.Node.Version -eq $InstalledApp.Version -or -not $InstalledApp)}
                $Element.Node.Status = $Config.Result        
            }
            
            # save package manager config
            $Xml.Save($AppDataFile)
        }          
    }    
}
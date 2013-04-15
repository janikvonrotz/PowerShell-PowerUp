if($Host.Version.Major -gt 2){
	powershell -Version 2 $MyInvocation.MyCommand.Definition
	exit
}

$Metadata = @{
	Title = "Profile Installation"
	Filename = "ProfileInstallation.ps1"
	Description = ""
	Tags = "powershell, profile, installation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-18"
	LastEditDate = "2013-04-11"
	Version = "4.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}else{

    [string]$WorkingPath = Get-Location
    #--------------------------------------------------#
    #  Settings
    #--------------------------------------------------#
    $PSConfig = .\Microsoft.PowerShell_profile.config.ps1

    #--------------------------------------------------#
    #  Includes
    #--------------------------------------------------#
    # Import Pscx Extension
	$env:PSModulePath += ";"+ ($PSConfig.modules.Path)
	Import-Module Pscx
    
    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#
  
    #Include functions
    $IncludeFolders = @()
    $IncludeFolders += $PSConfig.functions.Path
    $IncludeFolders += get-childitem ($PSConfig.functions.Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
    foreach ($IncludeFolder in $IncludeFolders){
	    Set-Location $IncludeFolder
	    get-childitem $IncludeFolder | where{ ! $_.PSIsContainer} | foreach {. .\$_}
    }
	Set-Location $WorkingPath
    
    # Add module path to the system variables
    Add-PathVariable -Value $PSconfig.modules.Path -Name PSModulePath -Target Machine
    
    #Load configurations
    $Configs = Get-ConfigurationFilesContent -Path $PSConfig.configs.Path -SearchExpression "*.profile.config.*"
	
    foreach($Config in $Configs){
        
        $Configuration = $Config.Content.Configuration

        # Registry Settings
        foreach ($RegistryEntry in $Configuration.RegistryEntries.RegistryEntry)
        {
	        Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
            [string]$Name =  $RegistryEntry.Name
		    Write-Warning "`nAdded registry entry: $Name"
        }

        # Add System Variables
        foreach ($SystemVariable in $Configuration.SystemVariables.SystemVariable)
        {
	        if($SystemVariable.RelativePath -eq "true")
	        {
                #Gets the static path from a relative path
		        $StaticPath = Convert-Path -Path (Join-Path -Path $(Get-Location).Path -Childpath $SystemVariable.Value)
                
		        Add-PathVariable -Value $StaticPath -Name $SystemVariable.Name -Target $SystemVariable.Target
	        }else{
		        Add-PathVariable -Value $SystemVariable.Value -Name $SystemVariable.Name -Target $SystemVariable.Target
	        }            [string]$Name =  $SystemVariable.Value
		    Write-Warning "`nAdded path variable: $Name"
        }
		
		#--------------------------------------------------#
        # Features
        #--------------------------------------------------#
	
	    foreach($Feature in $Configuration.Features.Feature){
		    if($Feature.Install -eq "Enable"){
			    switch($Feature.Name){

				    "Git Update Task" {

					    # Settings						
                        $PathToTask = Get-ChildItem -Path $PSConfigs.tasks.Path -Filter GitUpdateTask.xml -Recurse
						$PathToScript = Get-ChildItem -Path $PSConfigs.tasks.Path -Filter Git-Update.ps1 -Recurse
						
                        # Update task definitions
					    [xml]$TaskDefinition = (get-content $PathToTask.Fullname)
                        $TaskDefinition.Task.Actions.Exec.Arguments = $PathToScript.Fullname
					    $TaskDefinition.Task.Actions.Exec.WorkingDirectory = $WorkingPath
                        $TaskDefinition.Save($PathToTask.Fullname)

                        # Create task
                        [string]$Name =  $Feature.Name
                        SchTasks /Create /TN "$Name" /XML $PathToTask.Fullname
					    Write-Warning "`nAdded system task: $Name"
				    }
				
				    "Powershell Remoting"{

					    Enable-PSRemoting
					    Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
					    Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
					    restart-Service WinRM
					    Write-Warning "`nPowershell Remoting enabled"
				    }
                    
                    "Enable Open Powershell here"{
                    	Enable-OpenPowerShellHere
                    	Write-Warning "`nAdded 'Open PowerShell Here' to context menu"
                    }
			    }
		    }
	    }
	}
	
	
	#--------------------------------------------------#
	# Powershell Default Profile
	#--------------------------------------------------#

	# Create Powershell Profile
	if (!(Test-Path $Profile)){

		  # Create a profile
		New-Item -path $Profile -type file -force
	}

	# Link Powershell Profile
	$SourcePath = Split-Path $profile -parent
	$ScriptName = $MyInvocation.MyCommand.Name

	if (!(Test-Path ($SourcePath + "\" + $ScriptName) -PathType Leaf))
	{
		# Rename default source
		Rename-Item $SourcePath ($SourcePath + "-Obsolete")
 
		# Create a shortcut to the existing powershell profile
		New-Symlink $SourcePath $WorkingPath
	}
	
	Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green
	Read-Host "`nPress Enter to exit"

}
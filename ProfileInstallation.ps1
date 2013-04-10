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
	LastEditDate = "2013-04-10"
	Version = "3.1.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

if($Host.Version.Major -lt 2){
    throw "Only compatible with Powershell version 2 and higher"
}else{

    #--------------------------------------------------#
    #  Settings
    #--------------------------------------------------#
    [string]$WorkingPath = Get-Location
    $ModulesPath = "\modules"
    $FunctionPath = "\functions"

    #--------------------------------------------------#
    # Includes
    #--------------------------------------------------#
    $IncludeFolders = @()
    $IncludeFolders += $WorkingPath + $FunctionPath
    $IncludeFolders += get-childitem ($WorkingPath + $FunctionPath) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
    foreach ($IncludeFolder in $IncludeFolders){
	    Set-Location $IncludeFolder
	    get-childitem | where{ ! $_.PSIsContainer} | foreach {. .\$_}
    }

    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#

    # LoadConfig
    Set-Location $WorkingPath
    $xmlFile = [xml](get-content config.xml)
	$Configuration = $xmlFile.Content.Configuration

    # Registry Settings
    foreach ($RegistryEntry in $Configuration.RegistryEntries.RegistryEntry)
    {
	    Set-ItemProperty -Path $RegistryEntry.Path -Name $RegistryEntry.Name -Value $RegistryEntry.Value
        [string]$Name =  $RegistryEntry.Name
		Write-Host "`nAdded registry entry: $Name"  -BackgroundColor Yellow -ForegroundColor Black
    }

    # Import Pscx Extension
    $env:PSModulePath += ";"+ $WorkingPath + $ModulesPath
    Import-Module Pscx

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
	    }        [string]$Name =  $SystemVariable.Value
		Write-Host "`nAdded path variable: $Name"  -BackgroundColor Yellow -ForegroundColor Black
    }

    # Enable Open Powershell here
    Enable-OpenPowerShellHere
	Write-Host "`nAdded 'Open PowerShell Here' to context menu"  -BackgroundColor Yellow -ForegroundColor Black

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
	
    #--------------------------------------------------#
    # Features
    #--------------------------------------------------#
	
	foreach($Feature in $Configuration.Features.Feature){
		if($Feature.Install -eq "Enable"){
			switch($Feature.Name){
				"Git Update Task" {
					#Settings
                    $PathToTask = $WorkingPath + '\Tasks\Git Update Task.xml'
					$UpdateScriptName = "Git-Update.ps1"
					
                    [string]$Name =  $Feature.Name
					[xml]$TaskDefinition = (get-content $PathToTask)
                    $TaskDefinition.Task.Actions.Exec.Arguments = $WorkingPath + "\" + $UpdateScriptName
					$TaskDefinition.Task.Actions.Exec.WorkingDirectory = $WorkingPath
                    $TaskDefinition.Save($PathToTask)
                    SchTasks /Create /TN "$Name" /XML $PathToTask
					Write-Host "`nAdded system task: $Name"  -BackgroundColor Yellow -ForegroundColor Black
				}
				
				"Powershell Remoting"{
					Enable-PSRemoting
					Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force
					Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
					restart-Service WinRM
					Write-Host "`nPowershell Remoting enabled"  -BackgroundColor Yellow -ForegroundColor Black
				}
			}
		}
	}

	Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green
	Read-Host "`nPress Enter to exit"

}
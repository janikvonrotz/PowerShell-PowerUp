#***************************************************************************************
# Written by Craig Lussier - http://craiglussier.com
#
# This script installs SharePoint 2013 Roles/Features for Windows Server 2012
#  
# -Only run this script on Windows Server 2012 (RTM, either Standard or Datacenter)
# -If you are running this script 'offline' have your Windows Server 2012 installation
#  Media mounted/copied to this machine. You can also use a network UNC path.
# -Do not run this script on a Windows Server 2008 R2 SP1 Server!
# ---These are the Prerequisites for Windows Server 2012
# -Run this script as a local server Administrator
# -Run PowerShell as Administrator
#
# Don't forget to: Set-ExecutionPolicy RemoteSigned
# If you have not done so already within you Windows Server 2012 server 
#****************************************************************************************
# Import Required Module
Import-Module ServerManager

function AddWindowsFeatures() 
{ 
    Write-Host "==================================================================================="
    Write-Host "Install required Windows Roles/Features for SharePoint 2013 on Windows Server 2012"
    Write-Host ""
    Write-Host "Note: You'll receive prompt to restart your server when the"
    Write-Host "      Windows Server 2012 Role/Feature installation is complete."
    Write-Host "==================================================================================="        
     
      
    # Note: You can use the Get-WindowsFeature cmdlet (its in the ServerManager module) 
    #       to get a listing of all features and roles.
    $WindowsFeatures = @(
			"Net-Framework-Features",
			"Web-Server",
			"Web-WebServer",
			"Web-Common-Http",
			"Web-Static-Content",
			"Web-Default-Doc",
			"Web-Dir-Browsing",
			"Web-Http-Errors",
			"Web-App-Dev",
			"Web-Asp-Net",
			"Web-Net-Ext",
			"Web-ISAPI-Ext",
			"Web-ISAPI-Filter",
			"Web-Health",
			"Web-Http-Logging",
			"Web-Log-Libraries",
			"Web-Request-Monitor",
			"Web-Http-Tracing",
			"Web-Security",
			"Web-Basic-Auth",
			"Web-Windows-Auth",
			"Web-Filtering",
			"Web-Digest-Auth",
			"Web-Performance",
			"Web-Stat-Compression",
			"Web-Dyn-Compression",
			"Web-Mgmt-Tools",
			"Web-Mgmt-Console",
			"Web-Mgmt-Compat",
			"Web-Metabase",
			"Application-Server",
			"AS-Web-Support",
			"AS-TCP-Port-Sharing",
			"AS-WAS-Support",
			"AS-HTTP-Activation",
			"AS-TCP-Activation",
			"AS-Named-Pipes",
			"AS-Net-Framework",
			"WAS",
			"WAS-Process-Model",
			"WAS-NET-Environment",
			"WAS-Config-APIs",
			"Web-Lgcy-Scripting",
			"Windows-Identity-Foundation",
			"Server-Media-Foundation",
			"Xps-Viewer"
    )


    #Prompt To Start Role/Feature Installation
    $title = "Do you wish to perform an online or offline installation?"
    $message = "Please ensure that you have read and understand the instructions located at http://gallery.technet.microsoft.com/DownloadInstall-SharePoint-e6df9eb8. 'Online' means Windows Server 2012 is connected to the Internet and Windows Update is used to download supporting files, Offline means Windows Server 2012 is not connected to the Internet and you have your Windows Server 2012 installation media mounted/copied to this server to install supporting files."

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Online", `
	   "Uses Windows Update to download and install necessary components related to .NET 3.5 feature (NET-Framework-Core)"

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "O&ffline", `
           "Uses Windows Server 2012 media to install necessary components related to .NET 3.5 feature (NET-Framework-Core)"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    $windowsServer2012MediaPath = ""
    Write-Host ""

    switch ($result)
	{
        
        0 {"You will be using Windows Update to download the necessary components to install features related to .NET 3.5. This will extend the duration of your Role/Feature installation."}
        1 {$windowsServer2012MediaPath = $(Read-Host -Prompt "Please enter the directory pointing to the directory of your Windows Server 2012 installation media. Fore example, D:\sources\sxs")}
    }
    Write-Host ""


    Try 
    { 
	# Create PowerShell to execute 

        $source = "" 

        if($windowsServer2012MediaPath -ne "") {
           $source = ' -source ' + $windowsServer2012MediaPath
        }
        

        $myCommand = 'Add-WindowsFeature ' + [string]::join(",",$WindowsFeatures) + $source

	    # Execute $myCommand
        $operation = Invoke-Expression $myCommand    

        if ($operation.RestartNeeded -eq "Yes") { 
        
      	   #Prompt User for Restart
	   $title = "Restart your server now?"
	   $message = "Would you like to restart your server now? It is required to complete the Windows Role/Feature Installation."

	   $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
	         "Restarts your Windows Server 2012 server now to complete the Role/Feature installation."

	   $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
	    "Does not restart your server now... But you should..."

	   $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

	   $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

	   switch ($result)
	   {
	        0 {Restart-Computer;}
	        1 {"Your server will not restart at this time. Before installing the Pre-requisite files, restart your computer."}
	   }


        }

    } 
    Catch 
    { 
        Write-Warning "Error when Adding Windows Features. Error details are below:" 
        Write-Error $_ 
        break 
    } 
      
} 

AddWindowsFeatures
 

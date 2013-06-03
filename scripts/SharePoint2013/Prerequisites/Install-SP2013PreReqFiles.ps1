#***************************************************************************************
# Written by Craig Lussier - http://craiglussier.com
#
# This script downloads and instals SharePoint 2013 Prerequisites
#  
# -Only run this script on Windows Server 2012 (RTM, either Standard or Datacenter)
# -Do not run this script on a Windows Server 2008 R2 SP1 Server!
# ---These are the Prerequisites for Windows Server 2012
# -Run this script as a local server Administrator
# -Run PowerShell as Administrator
# 
# IMPORTANT NOTES:
# -The $SharePoint2013Path is the path to your SharePoint 2013 installation media
# -This script utilizes the PrerequisiteInstaller.exe in your SharePoint 2013 media
# -The script points to your $SharePoint2013Path\PrerequisiteInstallerFiles directory.
# ---BE SURE TO COPY THE PREREQ FILES INTO THIS DIRECTORY IF THEY ARE NOT ALREADY THERE FROM THE Download-SP2013PreReqFiles.ps1 script
#
# Don't forget to: Set-ExecutionPolicy RemoteSigned
# If you have not done so already within you Windows Server 2012 server
#****************************************************************************************
param([string] $SharePoint2013Path = $(Read-Host -Prompt "Please enter the directory path to where your SharePoint 2013 installation files exist.")) 
 

 
function InstallPreReqFiles() 
{ 

    $ReturnCode = 0

    Write-Host ""
    Write-Host "====================================================================="
    Write-Host "Installing Prerequisites required for SharePoint 2013" 
    Write-Host ""
    Write-Host "This uses the supported installing offline method"
    Write-Host ""
    Write-Host "If you have not installed the necessary Roles/Features"
    Write-Host "this will occur at this time."
    Write-Host "=====================================================================" 
     
     
        Try 
        { 
        

             Start-Process "$SharePoint2013Path\PrerequisiteInstaller.exe" -ArgumentList "`
                                                                                             /SQLNCli:`"$SharePoint2013Path\PrerequisiteInstallerFiles\sqlncli.msi`" `
                                                                                             /IDFX:`"$SharePoint2013Path\PrerequisiteInstallerFiles\Windows6.1-KB974405-x64.msu`" `
                                                                                             /IDFX11:`"$SharePoint2013Path\PrerequisiteInstallerFiles\MicrosoftIdentityExtensions-64.msi`" `
                                                                                             /Sync:`"$SharePoint2013Path\PrerequisiteInstallerFiles\Synchronization.msi`" `
                                                                                             /AppFabric:`"$SharePoint2013Path\PrerequisiteInstallerFiles\WindowsServerAppFabricSetup_x64.exe`" `
                                                                                             /KB2671763:`"$SharePoint2013Path\PrerequisiteInstallerFiles\AppFabric1.1-RTM-KB2671763-x64-ENU.exe`" `                                                                                             
                                                                                             /MSIPCClient:`"$SharePoint2013Path\PrerequisiteInstallerFiles\setup_msipc_x64.msi`" `
                                                                                             /WCFDataServices:`"$SharePoint2013Path\PrerequisiteInstallerFiles\WcfDataServices.exe`""
        } 
        Catch 
        { 
            $ReturnCode = -1 
            Write-Error $_ 
            break 
        }     
 
    return $ReturnCode 
} 
 
function CheckProvidedSharePoint2013Path()
{


    $ReturnCode = 0

    Try 
    { 
        # Check if destination path exists 
        If (Test-Path $SharePoint2013Path) 
        { 
           # Remove trailing slash if it is present
           $script:SharePoint2013Path = $SharePoint2013Path.TrimEnd('\')
	   $ReturnCode = 0
        }
        Else {

	   $ReturnCode = -1
           Write-Host ""
	   Write-Warning "Your specified download path does not exist. Please verify your download path then run this script again."
           Write-Host ""
        } 


    } 
    Catch 
    { 
         $ReturnCode = -1 
         Write-Warning "An error has occurred when checking your specified download path" 
         Write-Error $_ 
         break 
    }     
    
    return $ReturnCode 

}


 
function InstallPreReqs() 
{ 

    $rc = 0 
    
    $rc = CheckProvidedSharePoint2013Path  

     
    # Install the Pre-Reqs 
    if($rc -ne -1) 
    { 
       $rc = InstallPreReqFiles 
    } 

    if($rc -ne -1)
    {

        Write-Host ""
        Write-Host "Script execution is now complete!"
        Write-Host ""
    }


} 

InstallPreReqs

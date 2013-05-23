$Metadata = @{
	Title = "Set SharePoint Default Settings"
	Filename = "Set-SPDefaultSettings.ps1"
	Description = ""
	Tags = "powershell, script, sharepoint, settings"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-05-07"
	LastEditDate = "2013-05-23"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# modules
#--------------------------------------------------#
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

#--------------------------------------------------#
# default permission roles
#--------------------------------------------------#

$Assignments = @()

$Assignment = @{
	SPWebUrl = "http://sharepoint.vbl.ch/Projekte"
	GroupToAssign = "VBL\SP_Projekte#Superuser"
	RoleToAssignID = "1073741828"
}
$Assignments += $Assignment

$Assignment = @{
	SPWebUrl = "http://sharepoint.vbl.ch/Technik"
	GroupToAssign = "VBL\SP_Technik#Superuser"
	RoleToAssignID = "1073741828"
}
$Assignments += $Assignment

$Assignment = @{
	SPWebUrl = "http://sharepoint.vbl.ch"
	GroupToAssign = "VBL\SP_Home#Admin"
	RoleToAssignID = " 1073741829"
}
$Assignments += $Assignment

$Assignments | %{
    Assign-ADGroupPermissionRole -SPWebUrl $_.SPWebUrl -GroupToAssign $_.GroupToAssign -RoleToAssignID $_.RoleToAssignID
}

#--------------------------------------------------#
# lists default settings
#--------------------------------------------------#

# Get all Webapplictons
$SPWebApp = Get-SPWebApplication
# Get all sites
$SPSite = $SPWebApp | Get-SPsite -Limit all
# Get all websites
$SPWeb = $SPSite | Get-SPWeb -Limit all
# Get all lists
$SPLists = $SPweb | foreach{$_.Lists}
foreach ($SPList in $SPLists){
    # show progress
    Write-Progress -Activity "Change List Settings" -status "Change List: $SPList" -percentComplete ([int]([array]::IndexOf($SPLists, $SPList)/$SPLists.Count*100))
    
    # enable versioning
    $SPList.EnableVersioning = $True
    
    # set max document versions 
    $SPList.MajorVersionLimit = 10
    
    # change browser file handling from strict to permissive
    # if(
    # ($list.BaseType -ieq "DocumentLibrary") -and  
    # ($list.BrowserFileHandling -ieq "Strict") -and 
    # ($list.Hidden -eq $False) -and 
    # ($list.BaseTemplate -ieq "DocumentLibrary") -and 
    # ($list.IsSiteAssetsLibrary -ieq $False)
    # ){  
        # $list.BrowserFileHandling="Permissive"
    # }
    
    # update the settings
    $SPList.Update()
}

$Metadata = @{
	Title = "Assign Active Directory Group Permission Role"
	Filename = "Assign-ADGroupPermissionRole.ps1"
	Description = ""
	Tags = "powershell, activedirectory, sharepoint, role, assignment"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
	LastEditDate = "2013-05-17"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# settings
#--------------------------------------------------#
$SPSiteUrl =  "http://sharepoint.vbl.ch"
$SPWebUrl = "http://sharepoint.vbl.ch/Projekte"
$GroupToAssign = "VBL\SP_Projekte#Superuser"
$RoleToAssignID = "1073741828"


#--------------------------------------------------#
# main
#--------------------------------------------------#

$SPSite = Get-SPSite $SPSiteUrl
$SPRootWeb = $SPSite.RootWeb

# get spweb object
$SPweb = Get-SPweb $SPWebUrl

$GroupToAssign = $SPRootWeb.EnsureUser($GroupToAssign)

# get role definition by id
$RoleToAssign = $SPWeb.RoleDefinitions.GetById($RoleToAssignID)

# create a new role assignment object
$GroupToAssign = new-object Microsoft.SharePoint.SPRoleAssignment($GroupToAssign)
$GroupToAssign.RoleDefinitionBindings.Add($RoleToAssign)

foreach($SPSubweb in $SPweb.webs){
    
   $SPSubweb.RoleAssignments.Add($GroupToAssign)
   
}
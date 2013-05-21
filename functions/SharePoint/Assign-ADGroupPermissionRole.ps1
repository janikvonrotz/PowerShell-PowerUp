function Assign-ADGroupPermissionRole{
<#
.SYNOPSIS
	Assign active directory group permission

.DESCRIPTION
	Assigns a active directory group with a specific role to the subsites and lists of certain website.
	How to get the role ID: https://gist.github.com/janikvonrotz/5617921

.PARAMETER  SPWebUrl
	Web url of the sharepoint website that contains the subwebs and lists

.PARAMETER  GroupToAssign
	ActiveDirectory group name to assing
	
.PARAMETER  RoleToAssignID
	Role ID
	
.EXAMPLE
	Assign-ADGroupPermissionRole -SPWebUrl "http://sharepoint.vbl.ch/Projekte" -GroupToAssign "VBL\SP_Technik#Superuser" -RoleToAssignID "1073741828"

.NOTES
	

#>

	#--------------------------------------------------#
	# parameter
	#--------------------------------------------------#
	param(
		[Parameter(Mandatory=$true)]
		[string]$SPWebUrl,
		
		[Parameter(Mandatory=$true)]
		[string]$GroupToAssign,

		[Parameter(Mandatory=$true)]
		[string]$RoleToAssignID
	)
	
	$Metadata = @{
		Title = "Assign Active Directory Group Permission Role"
		Filename = "Assign-ADGroupPermissionRole.ps1"
		Description = "Assigns a active directory group with a specific role to the subsites and lists of certain website"
		Tags = "powershell, activedirectory, sharepoint, role, assignment"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "http://janikvonrotz.ch"
		CreateDate = "2013-05-17"
		LastEditDate = "2013-05-21"
		Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
		Add-PSSnapin “Microsoft.SharePoint.PowerShell”
	}


	#--------------------------------------------------#
	# main
	#--------------------------------------------------#

	$SPSiteUrl = Get-SPUrl $SPWebUrl -HostUrl
	$SPSite = Get-SPSite $SPSiteUrl
	$SPRootWeb = $SPSite.RootWeb

	# get spweb object
	$SPweb = Get-SPweb $SPWebUrl

	# get group sharepoint object
	$GroupToAssign = $SPRootWeb.EnsureUser($GroupToAssign)

	# get role definition by id
	$RoleToAssign = $SPWeb.RoleDefinitions.GetById($RoleToAssignID)

	# create a new role assignment object
	$GroupToAssign = new-object Microsoft.SharePoint.SPRoleAssignment($GroupToAssign)
	$GroupToAssign.RoleDefinitionBindings.Add($RoleToAssign)

	# set role for subwebs
	foreach($SPSubweb in $SPweb.webs){
		
		# only if not inherited
		if($SPSubweb.HasUniqueRoleAssignments){
		
			# assing role
			$SPSubweb.RoleAssignments.Add($GroupToAssign)
		}
		
		# sub web lists
		foreach($SPSubweblist in $SPSubweb.lists){
		
			 # only if not inherited
			if($SPSubweblist.HasUniqueRoleAssignments){
			
				# assing role
				$SPSubweblist.RoleAssignments.Add($GroupToAssign)
			}
		}
	}
}
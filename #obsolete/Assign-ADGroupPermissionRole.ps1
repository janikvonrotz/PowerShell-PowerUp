<#	
$Metadata = @{
    Title = "Assign Active Directory Group Permission Role"
    Filename = "Assign-ADGroupPermissionRole.ps1"
	Description = "Assigns a active directory group with a specific role to the subsites and lists of certain website"
	Tags = "powershell, activedirectory, sharepoint, role, assignment"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
	LastEditDate = "2013-06-28"
	Version = "2.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Assign-ADGroupPermissionRole{

<#
.SYNOPSIS
	Assign active directory group permission to a sharepoint website

.DESCRIPTION
	Assigns a active directory group with a specific role to a certain sharepoint website and if wished also to their child items.
    The roles are only assigned as long the sharepoint object doesn't inherit the rights.
	How to get the role ID: https://gist.github.com/janikvonrotz/5617921

.PARAMETER  SPWebUrl
	SharePoint website url

.PARAMETER  GroupToAssign
	ActiveDirectory group
	
.PARAMETER  RoleToAssignID
	Role ID
    
.PARAMETER IncludeChildItems
    Include SharePoint website child items
	
.EXAMPLE
	Assign-ADGroupPermissionRole -Url "http://sharepoint.domain.ch/Projekte" -GroupToAssign "VBL\SP_Technik#Superuser" -RoleToAssignID "1073741828" -IncludeChildItems

.Link
    https://gist.github.com/janikvonrotz/5617921
#>

	param(
		[Parameter(Mandatory=$true)]
		[string]$Url,
		
		[Parameter(Mandatory=$true)]
		[string]$GroupToAssign,

		[Parameter(Mandatory=$true)]
		[string]$RoleToAssignID,
        
        [switch]$IncludeChildItems
	)

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	if ((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null) {
		Add-PSSnapin 'Microsoft.SharePoint.PowerShell'
	}


	#--------------------------------------------------#
	# main
	#--------------------------------------------------#

    # get host url
	[Uri]$SPSiteUrl = $Url
    # create sp site object
	$SPSite = Get-SPSite ($SPSiteUrl.Scheme + "://" + $SPSiteUrl.Host)
    # get root web object
	$SPRootWeb = $SPSite.RootWeb

	# get spweb object
	$SPweb = Get-SPweb $Url
	# get role definition by id
	$RoleToAssign = $SPWeb.RoleDefinitions.GetById($RoleToAssignID)
	# create a new role assignment object
    $SPGroupToAssign = $SPRootWeb.EnsureUser($GroupToAssign)
    
    if($SPGroupToAssign -eq $Null){throw "Group not found!"}
    
	$SPGroupToAssign = new-object Microsoft.SharePoint.SPRoleAssignment($SPGroupToAssign)
	$SPGroupToAssign.RoleDefinitionBindings.Add($RoleToAssign)
    
    # set role to spweb
    if($SPweb.HasUniqueRoleAssignments){
        $SPweb.RoleAssignments.Add($SPGroupToAssign)
    }
            
	# set role for subwebs
	if($IncludeChildItems){
        foreach($SPSubweb in $SPweb.webs){
    		
    		# only if not inherited
    		if($SPSubweb.HasUniqueRoleAssignments){
    		
    			# assign role
    			$SPSubweb.RoleAssignments.Add($SPGroupToAssign)
    		}
    		
    		# sub web lists
    		foreach($SPSubweblist in $SPSubweb.lists){
    		
    			 # only if not inherited
    			if($SPSubweblist.HasUniqueRoleAssignments){
    			
    				# assing role
    				$SPSubweblist.RoleAssignments.Add($SPGroupToAssign)
    			}
    		}
        }
	}
}
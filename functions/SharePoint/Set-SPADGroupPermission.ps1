<#	
$Metadata = @{
    Title = "Set SharePoint ActiveDirectory Group Permission"
    Filename = "Set-SPADGroupPermission.ps1"
	Description = "Assigns a active directory group with a specific role to the subsites and lists of certain website"
	Tags = "powershell, activedirectory, sharepoint, role, assignment"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
	LastEditDate = "2013-08-13"
	Version = "3.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Set-SPADGroupPermission{

<#
.SYNOPSIS
	Assign active directory group permission to a sharepoint website.

.DESCRIPTION
	Assigns a active directory group with a specific role to a certain sharepoint website and if wished also to their child items.
    The roles are only assigned as long the sharepoint object doesn't inherit the rights.
	How to get the role ID: https://gist.github.com/janikvonrotz/5617921

.PARAMETER  Url
	SharePoint website url.

.PARAMETER  ADGroup
	ActiveDirectory group.
	
.PARAMETER  RoleID
	Role ID.
    
.PARAMETER Recursive
    Include SharePoint sube websites.
    
.PARAMETER IncludeLists
    Also set the permission for the list of the website.
    
.PARAMETER Overwrite
    Overwrite existing permissions by this group.
    	
.EXAMPLE
	Assign-ADGroupPermissionRole -Url "http://sharepoint.domain.ch/Projekte/SitePages/Homepage.aspx" -ADGroup "VBL\SP_Projekte#Superuser" -RoleToAssignID "1073741828" -Recursive

.Link
    https://gist.github.com/janikvonrotz/5617921
#>

	param(
		[Parameter(Mandatory=$true)]
		[string]$Url,
		
		[Parameter(Mandatory=$true)]
		[string]$ADGroup,

		[Parameter(Mandatory=$true)]
		[string]$RoleID,
        
        [switch]$Recursive,
        
        [switch]$IncludeLists,
        
        [switch]$Overwrite
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
    
    # extract spweb url
    $SPWebUrl = $(Get-CleanSPUrl -Url $Url).WebUrl
    
    # get spsite object
    $SPSite =  Get-SPSite ($SPWebUrl.Scheme + "://" + $SPWebUrl.Host)
    
    # get root web object
	$SPRootWeb = $SPSite.RootWeb

	# get spweb object
	$SPweb = Get-SPweb $SPWebUrl.OriginalString
    
	# get role definition by id
	$SPRole = $SPWeb.RoleDefinitions.GetById($RoleID)
    
	# create a new role assignment object
    $SPGroup = $SPRootWeb.EnsureUser($ADGroup)
    
    # abort if group doesn't exist
    if($SPGroup -eq $Null){throw "Group not found!"}
    
	$SPRoleAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($SPGroup)
	$SPRoleAssignment.RoleDefinitionBindings.Add($SPRole)

            
	# set role for subwebs
	if($Recursive){# recursive
    
        $SPWebs = Get-SPWebs -Url $SPweb.Url
        
        # set spwebs permission
        foreach($SPWeb in $SPWebs){
        
            Write-Progress -Activity "Update role assignment for $ADGroup" -status $SPWeb.title -percentComplete ([int]([array]::IndexOf(([array]$SPWebs), $SPWeb)/([array]$SPWebs).count*100))
        
            if($SPWeb.HasUniqueRoleAssignments){
                if($OverWrite){
                    $SPweb.RoleAssignments.Remove($SPGroup)
                }
    			$SPWeb.RoleAssignments.Add($SPRoleAssignment)
    		}
            
            # set splist permissions
            if($IncludeLists){
                
                # get lists of the websites
                $SPLists = Get-SPLists -Url $SPWeb.Url
                
                foreach($SPList in $SPLists){
                    if($SPList.HasUniqueRoleAssignments){ 
                        if($OverWrite){
                            $SPList.RoleAssignments.Remove($SPGroup)
                        }   			
        				$SPList.RoleAssignments.Add($SPRoleAssignment)
        			}                                     
                }            
            }        
        }       
    }else{# not recursive
     
        # set spweb permission
        if($SPWeb.HasUniqueRoleAssignments){
            if($OverWrite){
                $SPweb.RoleAssignments.Remove($SPGroup)
            }
			$SPWeb.RoleAssignments.Add($SPRoleAssignment)
		}
            
        # set splist permissions
        if($IncludeLists){
            
            # get lists of the websites
            $SPLists = Get-SPLists -Url $SPWeb.Url
            
            foreach($SPList in $SPLists){
                if($SPList.HasUniqueRoleAssignments){ 
                    if($OverWrite){
                        $SPList.RoleAssignments.Remove($SPGroup)
                    }   			
    				$SPList.RoleAssignments.Add($SPRoleAssignment)
    			}                                     
            }            
        }
    }
}
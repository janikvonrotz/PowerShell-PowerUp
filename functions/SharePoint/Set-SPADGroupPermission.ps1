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
	LastEditDate = "2013-12-09"
	Version = "3.4.0"
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

.PARAMETER Identity
	Url or PowerShell object of the SharePoint website.

.PARAMETER  ADGroup
	ActiveDirectory group  from the same domain.
	
.PARAMETER  Role
	Role ID or name.

.PARAMETER  Exclude
	Urls of websites to Exclude.
  
.PARAMETER Recursive
    Include SharePoint subwebsites.
    
.PARAMETER IncludeLists
    Also set the permission for the list of the website.
    
.PARAMETER Overwrite
    Overwrite existing permissions by this group.
    	
.EXAMPLE
	Assign-ADGroupPermissionRole -Identity "http://sharepoint.domain.ch/Projekte/SitePages/Homepage.aspx" -ADGroup "SP_Projekte#Superuser" -RoleToAssignID "1073741828" -Exclude "http://sharepoint.domain.ch/Projekte/Beta" -Recursive
#>

	param(
		[Parameter(Mandatory=$true)]
		$Identity,
		
		[Parameter(Mandatory=$true)]
		[string]$ADGroup,

		[Parameter(Mandatory=$true)]
		[string]$Role,
        
        [Parameter(Mandatory=$false)]
		[string[]]$Exclude,
        
        [switch]$Recursive,
        
        [switch]$IncludeLists,
        
        [switch]$Overwrite
	)

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
    Import-Module ActiveDirectory

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
 
	# get spweb object
    $SPWeb = Get-SPweb $(Get-SPUrl $Identity).Url
    
    # get spsite object
    $SPSite =  $SPWeb.Site
    
    # get root web object
	$SPRootWeb = $SPSite.RootWeb
    
	# get role definition by id
	$SPRole = $SPWeb.RoleDefinitions | where{$_.Name -eq $Role -or $_.ID -eq $Role}
    
    # get adgroup format domain\name
    $ADGroup = "$((Get-ADDomain).Name)" + "`\" + $(Get-ADGroup $ADGroup).Name
    
	# create a new role assignment object
    $SPGroup = $SPRootWeb.EnsureUser($ADGroup)
    
    # abort if group doesn't exist
    if($SPGroup -eq $Null){throw "Group not found!"}
    
	$SPRoleAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($SPGroup)
	$SPRoleAssignment.RoleDefinitionBindings.Add($SPRole)
    
    $("Grant $($SPRole.Name) access for $ADGroup on $($SPWeb.Title) with options:$(if($Recursive){" Recursive"})$(if($IncludeLists){" IncludeLists"})$(if($Overwrite){" Overwrite"})")
    
	# set role for subwebs
	if($Recursive){
    
        $SPWebs = Get-SPWebs $SPWeb | where{$Exclude -notcontains $_.Url} 
        
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
                $SPLists = Get-SPLists $SPWeb
                
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
        if($SPWebsite.HasUniqueRoleAssignments){
            if($OverWrite){
                $SPweb.RoleAssignments.Remove($SPGroup)
            }
			$SPWebsite.RoleAssignments.Add($SPRoleAssignment)
		}
            
        # set splist permissions
        if($IncludeLists){
            
            # get lists of the websites
            $SPLists = Get-SPLists $SPWebsite
            
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
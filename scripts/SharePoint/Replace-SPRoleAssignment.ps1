$Metadata = @{
	Title = "Replace SharePoint Role Assignments"
	Filename = "Replace-SPRoleSsignment.ps1"
	Description = ""
	Tags = "powershell, sharepoint, role, assignment"
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


if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin “Microsoft.SharePoint.PowerShell”
}

#--------------------------------------------------#
# settings
#--------------------------------------------------#
$RoleToChange = "Superuser"
# roledefinition edit
$RoleToAssign = $SPWeb.RoleDefinitions.GetById("1073741827")

# change for websites
Get-SPWebApplication | Get-SPsite -Limit all | %{ 
    $_ |  Get-SPWeb -Limit all | %{
        $_.RoleAssignments | %{
            if($_.roledefinitionbindings[0].Name -eq $RoleToChange){
                $_
                $_.roledefinitionbindings.RemoveAll()
                $_.roledefinitionbindings.Add($RoleToAssign)
                $_.Update()
            }
        }
    }
}

# change for lists
Get-SPWebApplication | Get-SPsite -Limit all | %{
    $_ |  Get-SPWeb -Limit all | %{
        $_.Lists | %{
            $_.RoleAssignments | %{
                if($_.roledefinitionbindings[0].Name -eq $RoleToChange){
                    $_
                    $_.roledefinitionbindings.RemoveAll()
                    $_.roledefinitionbindings.Add($RoleToAssign)
                    $_.Update()
                }
            }
        }
    }
}


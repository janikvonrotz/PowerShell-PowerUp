<#
$Metadata = @{
	Title = "Set-SPOListPermissions"
	Filename = "Set-SPOListPermissions.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = "https://sharepointpowershell.codeplex.com"
	Author = "Jeffrey Paarhuis"
	AuthorContact = "http://jeffreypaarhuis.com/"
	CreateDate = "2013-02-2"
	LastEditDate = "2014-02-2"
	Url = ""
	Version = "0.1.2"
	License = @'
The MIT License (MIT)
Copyright (c) 2014 Jeffrey Paarhuis
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'@
}
#>

function Set-SPOListPermissions
{
	[CmdletBinding()]
	param
	(	
		[Parameter(Mandatory=$true, Position=1)]
		[string]$groupname,

		[Parameter(Mandatory=$true, Position=2)]
		[string]$listname,

		[Parameter(Mandatory=$true, Position=3)]
		[string]$roleType
	)

	process
	{
		Write-Host "Creating permissions for list $listname for the group $groupname and role $roleType" -foregroundcolor black -backgroundcolor yellow

		# Try getting the SPWeb object

        $web = $clientContext.Web

        # get the Role
        $roleTypeObject = [Microsoft.SharePoint.Client.RoleType]$roleType
        $role = Get-SPORole $roleTypeObject

        # get the group principal object
        $group = Get-SPOGroup $groupname
 
        # get the list
        $list = $web.Lists.GetByTitle($listname)


        # calling nongeneric method clientContext.Load(list, x => x.HasUniqueRoleAssignments)
        $method = [Microsoft.Sharepoint.Client.ClientContext].GetMethod("Load")
        $loadMethod = $method.MakeGenericMethod([Microsoft.Sharepoint.Client.List])

        $parameter = [System.Linq.Expressions.Expression]::Parameter(([Microsoft.SharePoint.Client.List]), "x")
        $expression = [System.Linq.Expressions.Expression]::Lambda([System.Linq.Expressions.Expression]::Convert([System.Linq.Expressions.Expression]::Property($parameter, ([Microsoft.SharePoint.Client.List]).GetProperty("HasUniqueRoleAssignments")), ([System.Object])), $($parameter))
        $expressionArray = [System.Array]::CreateInstance($expression.GetType(), 1)
        $expressionArray.SetValue($expression, 0)

        $loadMethod.Invoke( $clientContext, @( $list, $expressionArray ) )


        $clientContext.ExecuteQuery()
 
        # break the inheritance if not done already
        if (-not $list.HasUniqueRoleAssignments)
        {
            $list.BreakRoleInheritance($false, $false) # don't keep the existing permissions and don't clear listitems permissions
        }

        $clientContext.ExecuteQuery()
 
        # create the role definition binding collection
        $rdb = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($clientContext)
 
        # add the role definition to the collection
        $rdb.Add($role)
 
        # create a RoleAssigment with the group and role definition
        $ra = $list.RoleAssignments.Add($group, $rdb)
 
        # execute the query to add everything
        $clientContext.ExecuteQuery()		

		Write-Host "Succesfully created permissions" -foregroundcolor black -backgroundcolor green
	}
}

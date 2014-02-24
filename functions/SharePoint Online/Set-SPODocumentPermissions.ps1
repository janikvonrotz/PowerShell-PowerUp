<#
$Metadata = @{
	Title = "Set-SPODocumentPermissions"
	Filename = "Set-SPODocumentPermissions.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = ""
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

function Set-SPODocumentPermissions
{
	[CmdletBinding()]
	param
	(	
		[Parameter(Mandatory=$true, Position=1)]
		[string]$groupname,

		[Parameter(Mandatory=$true, Position=2)]
		[string]$listname,

        [Parameter(Mandatory=$true, Position=3)]
        [string]$listItemName,

		[Parameter(Mandatory=$true, Position=4)]
		[string]$roleType
	)

	process
	{
		Write-Host "Creating permissions for document $listItemName in list $listname for the group $groupname and role $roleType" -foregroundcolor black -backgroundcolor yellow

		# Try getting the SPWeb object

        $web = $clientContext.Web

        # get the Role
        $roleTypeObject = [Microsoft.SharePoint.Client.RoleType]$roleType
        $role = Get-SPORole $roleTypeObject

        # get the group principal object
        $group = Get-SPOGroup $groupname
 
        # get the list
        $list = $web.Lists.GetByTitle($listname)


        $camlQuery = new-object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$listItemName</Value></Eq></Where></Query></View>"

        $listItems = $list.GetItems($camlQuery)


        
        $clientContext.Load($listItems)
        $clientContext.ExecuteQuery()

        if ($listItems.Count -gt 0)
        {
            
            $listItem = $listItems[0]

            $clientContext.Load($listItem)
            $clientContext.ExecuteQuery()


            # calling nongeneric method clientContext.Load(list, x => x.HasUniqueRoleAssignments)
            $method = [Microsoft.Sharepoint.Client.ClientContext].GetMethod("Load")
            $loadMethod = $method.MakeGenericMethod([Microsoft.Sharepoint.Client.ListItem])

            $parameter = [System.Linq.Expressions.Expression]::Parameter(([Microsoft.SharePoint.Client.ListItem]), "x")
            $expression = [System.Linq.Expressions.Expression]::Lambda([System.Linq.Expressions.Expression]::Convert([System.Linq.Expressions.Expression]::Property($parameter, ([Microsoft.SharePoint.Client.ListItem]).GetProperty("HasUniqueRoleAssignments")), ([System.Object])), $($parameter))
            $expressionArray = [System.Array]::CreateInstance($expression.GetType(), 1)
            $expressionArray.SetValue($expression, 0)

            $loadMethod.Invoke( $clientContext, @( $listItem, $expressionArray ) )

            $clientContext.ExecuteQuery()


            # break the inheritance if not done already
            if (-not $listItem.HasUniqueRoleAssignments)
            {
                $listItem.BreakRoleInheritance($false, $false) # don't keep the existing permissions and don't clear listitems permissions
            }

            $clientContext.ExecuteQuery()
 
            # create the role definition binding collection
            $rdb = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($clientContext)
 
            # add the role definition to the collection
            $rdb.Add($role)
 
            # create a RoleAssigment with the group and role definition
            $ra = $listItem.RoleAssignments.Add($group, $rdb)
 
            # execute the query to add everything
            $clientContext.ExecuteQuery()		

			Write-Host "Succesfully created permissions" -foregroundcolor black -backgroundcolor green

        } else {
			Write-Host "Item $listItemName could not be found" -foregroundcolor black -backgroundcolor red
        }
	}
}

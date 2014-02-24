<#
$Metadata = @{
	Title = "Add-SPOPrincipalToGroup"
	Filename = "Add-SPOPrincipalToGroup.ps1"
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

function Add-SPOPrincipalToGroup
{
	<#
	.SYNOPSIS
		Adds users or security groups to a SharePoint group
	.DESCRIPTION
		Adds users or security groups to a SharePoint group
	.PARAMETER username
		Username of the user or group including the domain. E.g. DOMAIN\User
	.PARAMETER groupname
		Name of the SharePoint group
	#>
	[CmdletBinding()]
	param
	(	
		[Parameter(Mandatory=$true, Position=1)]
		[string]$username,
		
		[Parameter(Mandatory=$true, Position=1)]
		[string]$groupname
	)

	process
	{
		Write-Host "Adding principal with username $username to group $groupname" -foregroundcolor black -backgroundcolor yellow

        $principal = Get-SPOPrincipal -username $username

		$group = Get-SPOGroup -name $groupname
		
		$userExists = $group.Users.GetById($principal.Id)
		$clientContext.Load($userExists)
		
		try
		{
			$clientContext.ExecuteQuery()
			
			# If no error then the principal already exists in the group
			
			Write-Host "Principal already added to the group" -foregroundcolor black -backgroundcolor yellow
			
		} 
		catch
		{
			# Error thrown that user doesn't exist
			
			$addedPrincipal = $group.Users.AddUser($principal)
		
			$clientContext.Load($addedPrincipal)
			$clientContext.ExecuteQuery()
			
			Write-Host "Succesfully added principal to the group" -foregroundcolor black -backgroundcolor green
		}
		
		
	}
}

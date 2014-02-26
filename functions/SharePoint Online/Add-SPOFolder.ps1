<#
$Metadata = @{
	Title = "Add-SPOFolder"
	Filename = "Add-SPOFolder.ps1"
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

function Add-SPOFolder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string]$folderUrl
	)
	
    # folder name
    $folderNameArr = $folderurl.Split('/')
    $folderName = $folderNameArr[$folderNameArr.length-1]
	# get server relative path of the sitecollection in there and remove the folder, cause thats being created right now
    $folderUrl = Join-SPOParts -Separator '/' -Parts $clientContext.Web.ServerRelativeUrl, $folderUrl
	$parentFolderUrl = $folderUrl.Replace('/' + $folderName,'')
    
 	
 
    # load the folder
    $web = $clientContext.Web
    $folder = $web.GetFolderByServerRelativeUrl($folderUrl)
    $clientContext.Load($folder)
    $alreadyExists = $false
 
    # check if the folder exists
    try
    {
        $clientContext.ExecuteQuery();
        # test if the folder already exists by checking its Path property
        if ($folder.Path)
        {
            $alreadyExists = $true;
        }
    }
    catch { }
 
    if (!$alreadyExists)
    {
        # folder doesn't exists so create it
		Write-Host "Create folder $folderName at $parentFolderUrl" -foregroundcolor black -backgroundcolor yellow
        
        # create the folder item
        $newItemInfo = new-object Microsoft.SharePoint.Client.ListItemCreationInformation
        $newItemInfo.UnderlyingObjectType = [Microsoft.SharePoint.Client.FileSystemObjectType]::Folder
        $newItemInfo.LeafName = $folderName
        $newItemInfo.FolderUrl = $parentFolderUrl
        
        # add the folder to the list
        $listUrl = Join-SPOParts -Separator '/' -Parts $clientContext.Web.ServerRelativeUrl, $folderNameArr[1]
		
		
		#$clientContext.LoadQuery($web.Lists.Where(list => list.RootFolder.ServerRelativeUrl -eq $listUrl))
		
		$method = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load")
		$loadMethod = $method.MakeGenericMethod([Microsoft.SharePoint.Client.List])

		$parameter = [System.Linq.Expressions.Expression]::Parameter(([Microsoft.SharePoint.Client.List]), "list")
		$expression = [System.Linq.Expressions.Expression]::Lambda(
			[System.Linq.Expressions.Expression]::Convert(
				[System.Linq.Expressions.Expression]::PropertyOrField(
					[System.Linq.Expressions.Expression]::PropertyOrField($parameter, "RootFolder"),
					"ServerRelativeUrl"
				),
				[System.Object]
			),
			$($parameter)
		)
		$expressionArray = [System.Array]::CreateInstance($expression.GetType(), 1)
		$expressionArray.SetValue($expression, 0)
		
		$lists = $web.Lists
		
		$clientContext.Load($lists)
		$clientContext.ExecuteQuery()
		
		$list = $null
		
		foreach	($listfinder in $lists) {
			$loadMethod.Invoke($clientContext, @($listfinder, $expressionArray))
			
			$clientContext.ExecuteQuery()
			
			if ($listfinder.RootFolder.ServerRelativeUrl -eq $listUrl)
			{
				$list = $listfinder
			}
		}
		
        $newListItem = $list.AddItem($newItemInfo)
 
        # item update
        $newListItem.Update()
 
        # execute it
        $clientContext.Load($list);
        $clientContext.ExecuteQuery();
    }
}

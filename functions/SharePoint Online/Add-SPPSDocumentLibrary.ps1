<#
$Metadata = @{
	Title = "Add-SPPSDocumentLibrary"
	Filename = "Add-SPPSDocumentLibrary.ps1"
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

function Add-SPPSDocumentLibrary
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string]$listTitle
	)
    $web = $clientContext.Web
    
    # Check if document library already exists
    $lists = $web.Lists
    $clientContext.Load($lists)
    $clientContext.ExecuteQuery()
    
    $listTitles = $lists | select -ExpandProperty Title
    
    if(!($listTitles -contains $listTitle))
    {
        $listCreationInfo = new-object Microsoft.SharePoint.Client.ListCreationInformation
        $listCreationInfo.TemplateType = [Microsoft.SharePoint.Client.ListTemplateType]::DocumentLibrary
        $listCreationInfo.Title = $listTitle
        $listCreationInfo.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::on

        $list = $web.Lists.Add($listCreationInfo)
        
        $clientContext.ExecuteQuery()
        
		Write-Host "Document Library '$listTitle' is created succesfully" -foregroundcolor black -backgroundcolor green
    }
    else
    {
		Write-Host "Document Library '$listTitle' already exists" -foregroundcolor black -backgroundcolor yellow
    }
}

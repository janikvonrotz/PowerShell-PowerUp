<#
$Metadata = @{
	Title = "Add-SPPSWebpart"
	Filename = "Add-SPPSWebpart.ps1"
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

function Add-SPPSWebpart
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
	    [string]$pageUrl,
		
		[Parameter(Mandatory=$true, Position=2)]
	    [string]$zone,
		
		[Parameter(Mandatory=$true, Position=3)]
	    [int]$order,
		
		[Parameter(Mandatory=$true, Position=4)]
	    [string]$webPartXml
	)
    
    Submit-SPPSCheckOut $pageUrl

	$targetPath = Join-SPPSParts -Separator '/' -Parts $clientContext.Site.ServerRelativeUrl, $pageUrl
	$page = $clientContext.Web.GetFileByServerRelativeUrl($targetPath)
    $webPartManager = $page.GetLimitedWebPartManager([Microsoft.SharePoint.Client.WebParts.PersonalizationScope]::Shared)
    $replacedWebPartXml = Convert-SPPSStringVariablesToValues -string $webPartXml
	$wpd = $webPartManager.ImportWebPart($replacedWebPartXml)
    $webPart = $webPartManager.AddWebPart($wpd.WebPart, $zone, $order);
    
    $clientContext.ExecuteQuery()

    Submit-SPPSCheckIn $pageUrl

	Write-Host "Web part succesfully added to the page $pageUrl" -foregroundcolor black -backgroundcolor green
}

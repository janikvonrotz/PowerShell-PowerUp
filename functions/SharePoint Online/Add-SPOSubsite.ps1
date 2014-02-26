<#
$Metadata = @{
	Title = "Add-SPOSubsite"
	Filename = "Add-SPOSubsite.ps1"
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

function Add-SPOSubsite
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
	    [string]$title,
		
		[Parameter(Mandatory=$false, Position=2)]
	    [string]$webTemplate = "STS#0",
		
		[Parameter(Mandatory=$false, Position=3)]
	    [string]$description = "",
		
		[Parameter(Mandatory=$false, Position=4)]
	    [string]$url = "",
		
		[Parameter(Mandatory=$false, Position=5)]
	    [int]$language = 1033,
		
		[Parameter(Mandatory=$false, Position=6)]
	    [bool]$useSamePermissionsAsParentSite = $true
	)
	Write-Host "Creating subsite $title" -foregroundcolor black -backgroundcolor yellow
	
	# Set url with title value when no url is set
	if ($url -eq "")
	{
		$url = $title
	}
	
	$webCreationInfo = new-object Microsoft.SharePoint.Client.WebCreationInformation
	$webCreationInfo.Title = $title
	$webCreationInfo.Description = $description
	$webCreationInfo.Language = $language
	$webCreationInfo.Url = $url
	$webCreationInfo.UseSamePermissionsAsParentSite = $useSamePermissionsAsParentSite
	$webCreationInfo.WebTemplate = $webTemplate
	
	$newSite = $clientContext.Web.Webs.Add($webCreationInfo)
		
    try {
	    
        $clientContext.ExecuteQuery()
        Write-Host "Subsite $title succesfully created" -foregroundcolor black -backgroundcolor green

    }	
    catch
    {
        
        Write-Host "Subsite $title already exists" -foregroundcolor black -backgroundcolor yellow

    }
}

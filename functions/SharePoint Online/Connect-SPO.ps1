<#
$Metadata = @{
	Title = "Connect-SPO"
	Filename = "Connect-SPO.ps1"
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

function Connect-SPO
{
	[CmdletBinding()]
	param
	(
	    [Parameter(Mandatory=$true, Position=1)]
	    [string]$siteURL,
		
		[Parameter(Mandatory=$false, Position=2)]
		[bool]$online,

	    [Parameter(Mandatory=$false, Position=3)]
	    [string]$username,

	    [Parameter(Mandatory=$false, Position=4)]
	    [string]$password
	)


	Write-Host "Loading the CSOM library" -foregroundcolor black -backgroundcolor yellow
	[Reflection.Assembly]::LoadFrom((Get-ChildItem -Path $PSlib.Path -Filter "Microsoft.SharePoint.Client.dll" -Recurse).FullName)
	Write-Host "Succesfully loaded the CSOM library" -foregroundcolor black -backgroundcolor green

	Write-Host "Create client context for site $siteUrl" -foregroundcolor black -backgroundcolor yellow
	$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
	
	$context.RequestTimeOut = 1000 * 60 * 10;

	if ($online)
	{
		Write-Host "Setting SharePoint Online credentials" -foregroundcolor black -backgroundcolor yellow
		
		$context.AuthenticationMode = [Microsoft.SharePoint.Client.ClientAuthenticationMode]::Default
		$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

		$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword)
		$context.Credentials = $credentials
	}

	Write-Host "Check connection" -foregroundcolor black -backgroundcolor yellow
	$site = $context.Site
	$context.Load($site)
	$context.ExecuteQuery()
	
	Set-Variable -Name "clientContext" -Value $context -Scope Global
	
	Write-Host "Succesfully connected" -foregroundcolor black -backgroundcolor green
}

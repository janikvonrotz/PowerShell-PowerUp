function Delete-SPlist{

<#
.DESCRIPTION
	Deletes SharePoint list

.PARAMETER  SiteUrl
	Url to the SharePoint website
	
.PARAMETER  Lists
	Array of the list titles to delete

.EXAMPLE
	Delete-SPlib -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Lists "Projektvorlagen"
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SiteUrl,
		
		[Parameter(Mandatory=$true)]
		[String[]]
		$Lists
	)

$Metadata = @{
	Title = "Delete SharePoint list"
	Filename = "Delete-SPlist.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-26"
	LastEditDate = "2013-04-26"
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	#--------------------------------------------------#
	# Modules
	#--------------------------------------------------#
	# Add SharePoint PowerShell Snapin
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    }
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	$HostUrl = Get-SPUrl $SiteUrl -HostUrl
	$HostSiteUrl = Get-SPUrl $SiteUrl -HostSiteUrl 
	$SiteUrl = Get-SPUrl $SiteUrl -SiteUrl
	
	foreach($List in $Lists){
		Write-Warning "Deleting " + $List + " on " + $HostSiteUrl
		$SPWeb = Get-SPWeb -Identity $HostSiteUrl
		$SPlist = $SPWeb.lists[$List]
		$SPlist.AllowDeletion = $true
		$SPlist.Update()
		$SPlist.Delete()
		Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
	}
	
}

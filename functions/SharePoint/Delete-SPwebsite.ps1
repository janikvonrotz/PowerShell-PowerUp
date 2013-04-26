function Delete-SPwebsite{

<#
.DESCRIPTION
	Deletes SharePoint website

.PARAMETER  SiteUrl
	Url to the SharePoint website
	
.EXAMPLE
	Delete-SPwebsite -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx"
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SiteUrl
	)

$Metadata = @{
	Title = "Delete SharePoint website"
	Filename = "Delete-SPwebsite.ps1"
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
	
	Write-Warning "Deleting " + $HostSiteUrl
	Remove-SPweb -Identity $HostSiteUrl
	Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
}

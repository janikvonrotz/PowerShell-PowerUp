function Import-SPwebsite{

<#
.DESCRIPTION
	Imports SharePoint website

.PARAMETER  SiteUrl
	Url to the SharePoint website, if the site doesn't exist create it manually before importing
	
.PARAMETER  Path
	Path to the export file

.EXAMPLE
	Import-SPwebsite -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Path "C:\temp\SharePointExport\Website Projekte 2013-04-26 11-15-26.cmp"
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SiteUrl,
				
		[Parameter(Mandatory=$true)]
		[String]
		$Path
	)

$Metadata = @{
	Title = "Import SharePoint website"
	Filename = "Import-SPwebsite.sp1"
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
	
	#Import SharePoint Website
	Write-Warning ("Importing " + $Path + " to " + $HostSiteUrl)
    Import-SPWeb HostSiteUrl -Path $Path -UpdateVersions Overwrite -IncludeUserSecurity -Force -NoLogFile
	
	# Error Workaround: Second import
	<#
	Import-SPWeb : <nativehr>0x80070003</nativehr><nativestack></nativestack>
	#>
	Import-SPWeb HostSiteUrl -Path $Path -UpdateVersions Overwrite -IncludeUserSecurity -Force -NoLogFile
	
	Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green	
}

function Import-SPlist{

<#
.DESCRIPTION
	Imports SharePoint list

.PARAMETER  SiteUrl
	Url to the SharePoint website
	
.PARAMETER  Path
	Path to the export file

.EXAMPLE
	Import-SPlist -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Path "C:\temp\SharePointExport\List Projektverwaltung 2013-04-26 11-15-26.cmp"
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
	Title = "Import SharePoint list"
	Filename = "Import-SPlist.ps1"
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
	# Settings
	#--------------------------------------------------#
	$SPFileExtension = $(Get-LogStamp) + ".cmp"
	
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
	$Host = Get-SPUrl $SiteUrl -Host
	$SiteUrl = Get-SPUrl $SiteUrl -SiteUrl
	$HostSiteUrl = Get-SPUrl $SiteUrl -HostSiteUrl 
	
	Write-Warning Importing $Path to $HostSiteUrl
	Import-SPWeb $HostSiteUrl -path $Path -IncludeUserSecurity -nologfile -Force
}

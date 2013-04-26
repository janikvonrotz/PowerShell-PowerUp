function Export-SPwebsite{

<#
.DESCRIPTION
	Export SharePoint website

.PARAMETER  SiteUrl
	Url to the SharePoint website

.PARAMETER  Path
	Path to the folder

	.OUTPUTS
		Path to website export file

.EXAMPLE
	Export-SPwebsite -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Path "C:\temp\SharePointExport"
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
	Title = "Export SharePoint website"
	Filename = "Export-SPwebsite.ps1"
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
	# Check if path exists
	if (!(Test-Path -path $Path)){New-Item $Path -Type Directory}
	
	$HostUrl = Get-SPUrl $SiteUrl -HostUrl
	$SiteUrl = Get-SPUrl $SiteUrl -SiteUrl
	$HostSiteUrl = Get-SPUrl $SiteUrl -HostSiteUrl

	# get website title
    $SPweb = Get-SPWeb $HostSiteUrl
    $SPSiteTitle = $SPweb.Title
	
	# file path
	$Path = $Path + "\Website " + $SPSiteTitle + $SPFileExtension
	
	Write-Warning Exporting $HostSiteUrl to $Path
	Export-SPWeb $HostSiteUrl -Path $Path -IncludeUserSecurity -IncludeVersions All  -Force -NoLogFile
	
	Write-Output $Path
	
}

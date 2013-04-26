function Export-SPlib{

<#
.DESCRIPTION
	Exports SharePoint library

.PARAMETER  SiteUrl
	Url to the SharePoint website
	
.PARAMETER  Path
	Path to the file

.EXAMPLE
	Export-SPlist -SiteUrl "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Librarys "Projektverwaltung" -Path "C:\temp\SharePointExport"
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
		$Librarys,
				
		[Parameter(Mandatory=$true)]
		[String]
		$Path
	)

$Metadata = @{
	Title = "Export SharePoint library"
	Filename = "Export-SPlist.ps1"
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
	$SPFileExtension = " " +$(Get-LogStamp) + ".cmp"
	
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
	$HostSiteUrl = Get-SPUrl $SiteUrl -HostSiteUrl 
	$SiteUrl = Get-SPUrl $SiteUrl -SiteUrl
	
	foreach($Library in $Librarys){
		Write-Warning "Exporting " + $HostSiteUrl + "/" +  $Library + " to " + $Path
		Export-SPWeb $HostSiteUrl -ItemUrl ($SiteUrl + "/" + $Library)  -path ($Path + "\Library " +$Library + $SPFileExtension) -IncludeUserSecurity -IncludeVersions All -nologfile -Force
		Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
	}
}

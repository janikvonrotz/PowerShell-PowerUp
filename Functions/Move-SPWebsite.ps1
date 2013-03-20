$Metadata = @{
	Title = "Move SharePoint Website"
	Filename = "Move-SPWebsite.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-20"
	LastEditDate = "2013-03-20"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

function Move-SPWebsite{
<#
	.SYNOPSIS
		Move a SharePoint Site from one place to another
 
	.DESCRIPTION
		.
 
	.PARAMETER  SPsiteSrcUrl
		Source Url of the SharePoint Site
 
	.PARAMETER  SPsiteDestUrl
		Destination Url of the SharePoint Site
 
	.EXAMPLE
		Move-SPWebsite -SPsiteSrcUrl http://sharepoint.vbl.ch/Direktion/SitePages/Homepage.aspx -SPsiteDestUrl http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx
 
	.INPUTS
		.
 
	.OUTPUTS
		.
 
	.NOTES
		Import-SPWeb: http://technet.microsoft.com/de-de/library/ff607613.aspx
		Export-SPWeb: http://technet.microsoft.com/de-ch/library/ff607895.aspx
		Remove-SPSite: http://technet.microsoft.com/en-us/library/ff607948.aspx
 
	.LINK
		.
 
#>
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
		[parameter(Mandatory=$true)]
		[String]
		$SPsiteSrcUrl,
		[parameter(Mandatory=$true)]
		[String]
		$SPsiteDestUrl
	)

	#--------------------------------------------------#
	# Settings
	#--------------------------------------------------#
    $LocalTempExportPath = "C:\temp\SharePointExport\"
	$SPFileExtension = $(Get-LogStamp) + ".cmp"
	
	#--------------------------------------------------#
	# Includes
	#--------------------------------------------------#
	# Add SnapIn
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    }

	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	
	# Create the temporary folder
	if (!(Test-Path -path $LocalTempExportPath)) {New-Item $LocalTempExportPath -Type Directory}
	
	# Urls cleanup
	$SPsiteSrcUrl = ([System.Uri]$SPsiteSrcUrl).LocalPath -replace "/SitePages/Homepage.aspx", ""
    $SPsiteDestUrl = ([System.Uri]$SPDestWebUrl).LocalPath -replace "/SitePages/Homepage.aspx", ""
	
	#Export SharePoint Website
	Write-Host ("`nExporting " + $SPsiteSrcUrl) -BackgroundColor Yellow -ForegroundColor Black
	Export-SPWeb $SPsiteSrcUrl -Path ($LocalTempExportPath+$SPFileExtension) -Force -IncludeUserSecurity -IncludeVersions
	
	#Import SharePoint Website
	Write-Host ("`nImporting " + $SPsiteDestUrl) -BackgroundColor Yellow -ForegroundColor Black
	Import-SPWeb SPsiteDestUrl –Path ($LocalTempExportPath+$SPFileExtension) –UpdateVersions Overwrite -IncludeUserSecurity -Force
	
	#Remoe SharePoint Website Source
	$Choice = Read-Host "`nDelete the Source (y/n)?"
	if($Choice -eq "y"){
		Write-Host ("`n Deleting " + $SPsiteSrcUrl) -BackgroundColor Yellow -ForegroundColor Black
		Remove-SPSite -Identity $SPsiteSrcUrl -GradualDelete -Confirm:$False
	}
	
}
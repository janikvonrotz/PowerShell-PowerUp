$Metadata = @{
	Title = "Move SharePoint Website"
	Filename = "Move-SPWebsite.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-20"
	LastEditDate = "2013-03-25"
	Version = "1.0.1"
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
	$SPsiteSrcUrl = ("http://" + ([System.Uri]$SPsiteSrcUrl).Host + ([System.Uri]$SPsiteSrcUrl).LocalPath) -replace "/SitePages/Homepage.aspx", ""
    $SPsiteDestUrl = ("http://" + ([System.Uri]$SPsiteDestUrl).Host + ([System.Uri]$SPsiteDestUrl).LocalPath) -replace "/SitePages/Homepage.aspx", ""
	
	#Export SharePoint Website
    $SPweb = Get-SPWeb $SPsiteSrcUrl
    $SPSiteTitle = $SPweb.Title
        
	Write-Host ("`nExporting " + $SPsiteSrcUrl) -BackgroundColor Yellow -ForegroundColor Black
	Export-SPWeb $SPsiteSrcUrl -Path ($LocalTempExportPath + $SPSiteTitle + $SPFileExtension) -IncludeUserSecurity -IncludeVersions All  -Force -NoLogFile  -WhatIf
	Export-SPWeb $SPsiteSrcUrl -Path ($LocalTempExportPath + $SPSiteTitle + $SPFileExtension) -IncludeUserSecurity -IncludeVersions All  -Force -NoLogFile  -Confirm
	
    #Create the destination site
    $SPSiteDestUrl += "/" + $SPSiteTitle
    
    Write-Host ("`nCreating " + $SPSiteDestUrl) -BackgroundColor Yellow -ForegroundColor Black    
    New-SPWeb ($SPSiteDestUrl) -Template "STS#0" -WhatIf
    New-SPWeb ($SPSiteDestUrl) -Template "STS#0" -Confirm
    
    #Update the title
    $SPweb = Get-SPWeb $SPSiteDestUrl
    $SPweb.Title = $SPSiteTitle
    $SPweb.Update()
        
	#Import SharePoint Website
	Write-Host ("`nImporting to " + $SPsiteDestUrl) -BackgroundColor Yellow -ForegroundColor Black
	Import-SPWeb $SPsiteDestUrl -Path ($LocalTempExportPath + $SPSiteTitle + $SPFileExtension) -UpdateVersions Overwrite -IncludeUserSecurity -Force -NoLogFile -WhatIf
    Import-SPWeb $SPsiteDestUrl -Path ($LocalTempExportPath + $SPSiteTitle + $SPFileExtension) -UpdateVersions Overwrite -IncludeUserSecurity -Force -NoLogFile -Confirm
    
	#Remoe SharePoint Website Source
	Write-Host ("`n Deleting " + $SPsiteSrcUrl) -BackgroundColor Yellow -ForegroundColor Black
    Remove-SPweb -Identity $SPsiteSrcUrl -WhatIf
	Remove-SPweb -Identity $SPsiteSrcUrl -Confirm
    
    Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black

}
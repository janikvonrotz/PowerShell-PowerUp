function Get-SPUrl{

<#
.DESCRIPTION
	Cleans SharePoint website url

.PARAMETER  SPUrl
	SharePoint website Url

.PARAMETER  HostUrl
	Returns the host url

.PARAMETER  SiteUrl
	Returns clean site url segement

.PARAMETER  HostSiteUrl
	Returns the host url and a clean site url segement
	
.EXAMPLE
	Get-SPUrl -SiteUrl "http://sharepoint.vbl.ch/Prozesse%20und%20Dokumente/SitePages/Homepage.aspx" -HostSiteUrl
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SPurl,
				
		[switch]
		$HostUrl,

		[switch]
		$SiteUrl,

		[switch]
		$HostSiteUrl		
	)

$Metadata = @{
	Title = "Get SharePoint Url"
	Filename = "Get-SPUrl.ps1"
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
	# Main
	#--------------------------------------------------#
		
	if($HostUrl){
		$HostUrlValue = ([System.Uri]$SPUrl).Scheme + "://" + ([System.Uri]$SPUrl).Host
		Write-Output $HostUrlValue
	}
	if($HostSiteUrl){
		$HostSiteUrlValue = (([System.Uri]$SPUrl).Scheme + "://" + ([System.Uri]$SPUrl).Host + ([System.Uri]$SPUrl).LocalPath) -replace "/SitePages/Homepage.aspx", "" 
		Write-Output $HostSiteUrlValue
	}
	if($SiteUrl){
		$SiteUrlValue = (([System.Uri]$SPUrl).LocalPath) -replace "/SitePages/Homepage.aspx", "" 
		Write-Output $SiteUrlValue
	}

}

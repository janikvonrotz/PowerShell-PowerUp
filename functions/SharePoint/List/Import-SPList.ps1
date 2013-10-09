<#
$Metadata = @{
	Title = "Import SharePoint list"
	Filename = "Import-SPList.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-26"
	LastEditDate = "2013-10-08"
	Version = "2.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Import-SPList{

<#
.DESCRIPTION
	Imports a SharePoint list

.PARAMETER  Url
	Url to the SharePoint website
	
.PARAMETER  Path
	Path to the export file

.EXAMPLE
	Import-SPlist -Url "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -Path "C:\temp\SharePointExport\List Projektverwaltung 2013-04-26 11-15-26.bak"
#>
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Url,
				
		[Parameter(Mandatory=$true)]
		[String]
		$Path,
        
        [Switch]
        $NoFileCompression
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){
        Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    }
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#	
    $SPUrl = $(Get-CleanSPUrl -Url $Url).WebUrl    
    $Identity = $SPUrl.Scheme + "://" + $SPUrl.Host + $SPUrl.LocalPath
    Write-Host "Import SharePoint list export $Path to $Identity"
	Import-SPWeb -Identity $Identity -path $Path -IncludeUserSecurity -nologfile -Force -NoFileCompression:$NoFileCompression
}
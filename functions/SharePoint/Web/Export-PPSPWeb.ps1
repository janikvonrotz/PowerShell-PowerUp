<#
$Metadata = @{
  Title = "Export SharePoint Website"
	Filename = "Export-PPSPWeb.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, export"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-04"
	LastEditDate = "2013-07-04"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Export-PPSPWeb{

<#
.SYNOPSIS
	Export a SharePoint website.

.DESCRIPTION
	Export a SharePoint website.

.PARAMETER Url
	Url of the SharePoint website.
	
.PARAMETER  Path
	Path to the backup folders. Optional, default is c:\temp.
    
.PARAMETER  NoFileCompression
	Provide this parameter if the compressed website is oversized.
	    
.EXAMPLE
	PS C:\> Export-PPSPWeb -Identity http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx -Path C:\Backup -NoFileCompression

#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Url,
		
		[Parameter(Mandatory=$false)]
		[String]
		$Path = "C:\temp",
        
        [Switch]
        $NoFileCompression
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#	
	if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
        
    # extract spweb url
    $SPUrl = $(Get-SPUrl $Url).Url
    
    # get spweb object
    $SPWeb = Get-SPWeb -Identity $SPUrl
    
    $SPTemplate = $SPWeb.WebTemplate + "#" + $SPWeb.WebTemplateID
    
    # check the backup folder    
    if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
    
    # create the backup filename
    $FileName = $SPWeb.Title + "#" + $((get-date -format o) -replace ":","-") + ".bak"
    
    # create the backup filepath
    $FilePath = Join-Path $Path -ChildPath $FileName
    
    # export spweb
    Export-SPWeb -Identity $SPWeb.Url -Path $FilePath -Force -IncludeUserSecurity -IncludeVersions All -NoFileCompression:$NoFileCompression -NoLogFile

    # write output
    @{BackupFile = $FilePath;Template = $SPTemplate}
    
}
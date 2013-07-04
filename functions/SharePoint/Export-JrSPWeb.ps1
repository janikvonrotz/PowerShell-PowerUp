<#
$Metadata = @{
  Title = "Export SharePoint Website"
	Filename = "Export-JrSPWeb.ps1"
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

function Export-JrSPWeb{

<#
.SYNOPSIS
	Export a SharePoint website.

.DESCRIPTION
	Export a SharePoint website.

.PARAMETER Identity
	Url of the SharePoint website.
	
.PARAMETER  Path
	Path to the backup folders.
	
.PARAMETER  AddTimeStamp
	Add a time stamp to the export filename.
    
.EXAMPLE
	PS C:\> Export-SPWeb -Identity http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx -Path C:\Backup -AddTimeStamp

#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Identity,
		
		[Parameter(Mandatory=$true)]
		[String]
		$Path,
        
        [Switch]
		$AddTimeStamp        
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#	
	if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
	{
		Add-PSSnapin "Microsoft.SharePoint.PowerShell"
	}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # get url
    [Uri]$SPWebUrl = $Identity
    
    # extract spweb url
    $SPWebUrl = $SPWebUrl.ToString().TrimEnd("/SitePages/Homepage.aspx")
    
    # get spweb object
    $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString
    
    # check the backup folder    
    if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
    
    # create the backup filename
    $FileName = $SPWeb.Title + $(if($AddTimeStamp){"#" + $(Get-LogStamp)}) + ".bak"
    
    # create the backup filepath
    $FilePath = Join-Path $Path -ChildPath $FileName
    
    # export spweb
    Export-SPWeb -Identity $SPWeb.Url -Path $FilePath -Force -IncludeUserSecurity -IncludeVersions all -NoFileCompression -NoLogFile

    # finisher
    Write-Host "Finished" -ForegroundColor Green
}
<#
$Metadata = @{
	Title = "Move SharePoint Website"
	Filename = "Move-SPWeb.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://www.janikvonrotz.ch"
	CreateDate = "2013-11-26"
	LastEditDate = "2013-11-26"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Move-SPWeb{

<#
.DESCRIPTION
	Move a SharePoint list

.PARAMETER  SourceUrl
	Source Url of the website to move.
	
.PARAMETER  DestUrl
	Destination Url of the website to replace.

.PARAMETER  NoFileCompression
	Provide this parameter if the compressed list is oversized.

.EXAMPLE
	Move-SPWeb -SourceUrl -DestUrl
#>
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SourceUrl,
				
		[Parameter(Mandatory=$true)]
		[String]
		$DestUrl,
        
        [Switch]
        $NoFileCompression
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
    if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#	
    $Export = (Export-PPSPWeb -Url $SourceUrl -NoFileCompression:$NoFileCompression)
    $Export
    Import-PPSPWeb -Url $DestUrl -Path $Export.BackupFile -NoFileCompression:$NoFileCompression -Template $Export.Template
    
    Write-Host "Remove item $Path"
    Remove-Item -Path $Export.BackupFile -Force -confirm:$false -Recurse
}
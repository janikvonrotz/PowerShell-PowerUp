<#
$Metadata = @{
	Title = "Move SharePoint list"
	Filename = "Move-SPList.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://www.janikvonrotz.ch"
	CreateDate = "2013-10-10"
	LastEditDate = "2013-11-19"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Move-SPList{

<#
.DESCRIPTION
	Move a SharePoint list

.PARAMETER  ListUrl
	Source Url of the List.
	
.PARAMETER  WebUrl
	Destination Url of the Website.

.PARAMETER  NoFileCompression
	Provide this parameter if the compressed list is oversized.

.EXAMPLE
	Move-SP-List
#>
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$ListUrl,
				
		[Parameter(Mandatory=$true)]
		[String]
		$WebUrl,
        
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
    $Path = (Export-SPList -ListUrl $ListUrl -NoFileCompression:$NoFileCompression)
    Import-SPList -WebUrl $WebUrl -Path $Path -NoFileCompression:$NoFileCompression
    
    Write-Host "Remove item $Path"
    Remove-Item -Path $Path -Force -confirm:$false -Recurse
}
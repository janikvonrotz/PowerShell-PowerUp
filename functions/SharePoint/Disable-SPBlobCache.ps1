<#
$Metadata = @{
	Title = "Disable-SPBlobCache"
	Filename = "Disable-SPBlobCache.ps1"
	Description = ""
	Tags = "sharepoint, disable, blob, cache"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-04-08"
	LastEditDate = "2014-04-08"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Disable-SPBlobCache{

<#
.SYNOPSIS
    Disable SharePoint Blob Cache.

.DESCRIPTION
	Disable SharePoint Blob Cache.

.PARAMETER SPWebApplication
	On this SharePoint web application Blob cach will be disabled.
	
.EXAMPLE
	PS C:\> Get-SPWebApplication | Disable-SPBlobCache

.LINK
	http://blogs.technet.com/b/heyscriptingguy/archive/2010/09/14/use-powershell-to-script-changes-to-the-sharepoint-web-config-file.aspx

#>

    [CmdletBinding()]
    param( 
	
		[Parameter(Mandatory=$true)]
		[Microsoft.SharePoint.PowerShell.SPWebApplicationPipeBind]
		$SPWebApplication
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#       
	$SPWebApp = $SPWebApplication.Read()
	$Mods = @()
	foreach($Mod in $SPWebApp.WebConfigModifications){
		if($Mod.Owner -eq "BlobCacheMod"){
			$Mods += $Mod
		}
	  }

	foreach($Mod in $Mods){
		[void] $SPWebApp.WebConfigModifications.Remove($Mod)
	}

	$SPWebApp.Update()
	$SPWebApp.Parent.ApplyWebConfigModifications()
} 

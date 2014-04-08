<#
$Metadata = @{
	Title = "Enable-SPBlobCache"
	Filename = "Enable-SPBlobCache.ps1"
	Description = ""
	Tags = "sharepoint, enable, blob, cache"
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

function Enable-SPBlobCache{

<#
.SYNOPSIS
    Enable SharePoint Blob Cache.

.DESCRIPTION
	Enable SharePoint Blob Cache.

.PARAMETER SPWebApplication
	On this SharePoint web application Blob cach will be enabled.

.PARAMETER Path
	Path to the cache folder. Default is "E:\Blobcache".
	
.EXAMPLE
	PS C:\> Get-SPWebApplication | Enable-SPBlobCache

.LINK
	http://blogs.technet.com/b/heyscriptingguy/archive/2010/09/14/use-powershell-to-script-changes-to-the-sharepoint-web-config-file.aspx

#>

    [CmdletBinding()]
    param( 
	
		[Parameter(Mandatory=$true)]
		[Microsoft.SharePoint.PowerShell.SPWebApplicationPipeBind]
		$SPWebApplication,
		
		[Parameter(Mandatory=$false)]
		[String]
		$Path = "E:\Blobcache"
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#        
	$SPWebApp = $SPWebApplication.Read()

	# SPWebConfigModification to enable BlobCache
	$configMod1 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
	$configMod1.Path = "configuration/SharePoint/BlobCache" 
	$configMod1.Name = "enabled" 
	$configMod1.Sequence = 0
	$configMod1.Owner = "BlobCacheMod" 
	
	## SPWebConfigModificationType.EnsureChildNode -> 0
	## SPWebConfigModificationType.EnsureAttribute -> 1
	## SPWebConfigModificationType.EnsureSection -> 2
	$configMod1.Type = 1
	$configMod1.Value = "true" 

	# SPWebConfigModification to enable client-side Blob caching (max-age)
	$configMod2 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
	$configMod2.Path = "configuration/SharePoint/BlobCache" 
	$configMod2.Name = "max-age" 
	$configMod2.Sequence = 0
	$configMod2.Owner = "BlobCacheMod" 

	## SPWebConfigModificationType.EnsureChildNode -> 0
	## SPWebConfigModificationType.EnsureAttribute -> 1
	## SPWebConfigModificationType.EnsureSection -> 2
	$configMod2.Type = 1
	$configMod2.Value = "86400" 
	
	# SPWebConfigurationModification to move blobstore location
	$configMod3 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
	$configMod3.Path = "configuration/SharePoint/BlobCache" 		
	$configMod3.Name = "location"
	$configMod3.Sequence = 0
	$configMod3.Owner = "BlobCacheMod" 
	$configMod3.Type = 1
	$configMod3.Value = $Path
	
	# Add mods, update, and apply
	$SPWebApp.WebConfigModifications.Add($configMod1)
	$SPWebApp.WebConfigModifications.Add($configMod2)
	$SPWebApp.WebConfigModifications.Add($configMod3)
	$SPWebApp.Update()
	$SPWebApp.Parent.ApplyWebConfigModifications()
} 
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
	LastEditDate = "2013-10-10"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Move-SPList{

<#
.SYNOPSIS
    Copy SharePoint permission form a securable object to another.
  
.DESCRIPTION
	Copy SharePoint permission form a securable object to another by providing an Url or an SharePoint securable object.

.PARAMETER  SourceObject
	Source securable object.
	
.PARAMETER  DestObject
	Destination SharePoint securable object.

.PARAMETER  Merge
	By default the exsting permissions will be overwritten, by enable this parameter
    the permission will be merged together, eminence thereby have the permissions to copy.

.EXAMPLE
	Copy-SPPermissions
#>
	
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$SourceObject,
				
		[Parameter(Mandatory=$true)]
		[String]
		$DestObject,
        
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
    if($SourceObject.PsObject.TypeNames -contains "System.String"){
        
    }elseif($SourceObject.PsObject.TypeNames -contains "Microsoft.SharePoint.SPWeb"){
          
    }elseif($SourceObject.PsObject.TypeNames -contains "Microsoft.SharePoint.SPList"){
    
    }else{
        throw ""
    }
    
    
    if($DestObject.PsObject.TypeNames -contains "System.String"){
        
    }elseif($DestObject.PsObject.TypeNames -contains "Microsoft.SharePoint.SPWeb"){
          
    }elseif($DestObject.PsObject.TypeNames -contains "Microsoft.SharePoint.SPList"){
    
    }else{
        throw ""
    }
}
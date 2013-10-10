<#
$Metadata = @{
  Title = "Get SharePoint Url"
	Filename = "Get-SPUrl.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint, list, url"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-09"
	LastEditDate = "2013-10-09"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPUrl {

<#
.SYNOPSIS
    Get Url from a SharePoint object.

.DESCRIPTION
	This function returns a normalized url to the provided SharePoint object or http url.

.PARAMETER  Object
	SharePoint Object.

.INPUTS
	System.Object

.OUTPUTS
	System.Uri

.EXAMPLE
	PS C:\> Get-SPUrl -Object $SharePointListObject
    
.EXAMPLE
	PS C:\> Get-SPUrl -Object "http://sharepoint.domain.ch/Projekte/SitePages/Homepage.aspx"
#>

	param(
		[Parameter(Mandatory=$true)]
		$Object
	)
    	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    if($Object.PsObject.TypeNames -contains "System.String"){
    
        [Uri]$Url = $Object
      	
    	if($Url -match "(/Forms/).*?\.(aspx$)"){
            
            # Library
            New-Object PSObject -Property @{
                ListUrl = ($Url.AbsoluteUri -replace "(/Forms/).*?\.(aspx)","")
                WebUrl = ($Url.AbsoluteUri -replace "/([^/]*)(/Forms/).*?\.(aspx)","")
            }  
            
        }elseif($Url -match "(/Lists/).*?\.(aspx$)"){
        
            # List
            New-Object PSObject -Property @{
                ListUrl = ($Url.AbsoluteUri -replace "/([^/]*)\.(aspx)","")
                WebUrl = ($Url.AbsoluteUri -replace "(/Lists/).*?\.(aspx)","")
            } 
            
        }elseif($Url -match "/SitePages/Homepage.aspx$" -or $Url -match "/default.aspx$"){
        
            # Website
            New-Object PSObject -Property @{
                WebUrl = ($Url.AbsoluteUri -replace "/SitePages/Homepage.aspx", "" -replace "/default.aspx","")
            }
            
    	}elseif($Url -match "_vti_history"){
        
            # Documentlibrary Listitem File Subversion
            New-Object PSObject -Property @{
                ListItemFileUrl = (($Url.AbsoluteUri -replace "_vti_history/(.*[0-9])/","")  -replace "\\","/")
            }            
        
        }else{ 
        
            # no match
            New-Object PSObject -Property @{
                Url = $Url.OriginalString
            }
    	}
        
    }elseif($Object.PsObject.TypeNames -contains "Microsoft.SharePoint.SPList"){
    
        New-Object PSObject -Property @{
            Url = (([Uri]$Object.Parentweb.Url).Scheme + "://" + ([uri]$Object.Parentweb.Url).host + $Object.RootFolder.ServerRelativeUrl)
        }
        
    }elseif($Object.PsObject.TypeNames -contains "Microsoft.SharePoint.SPWeb"){
    
        New-Object PSObject -Property @{
            Url = $Object.Url
        }
        
    }elseif($Object.PsObject.TypeNames -contains "Microsoft.SharePoint.SPListItem"){
    
        New-Object PSObject -Property @{
            Url = ($Object.ParentList.ParentWeb.Url + "/" + $Object.Url)
        }
    }        
}
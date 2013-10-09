<#
$Metadata = @{
  Title = "Get-CleanSPUrl"
	Filename = "Get-CleanSPUrl.ps1"
	Description = "function is obsolete use Get-SPUrl instead."
	Tags = "powershell, function, sharepoint, cleant, website, url"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-08-07"
	LastEditDate = "2013-10-09"
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-CleanSPUrl {

<#
.SYNOPSIS
    function is obsolete use Get-SPUrl instead.

.DESCRIPTION
	This function recognize the url type and outputs a clean version which is usable with SharePoint functions.

.PARAMETER  Url
	Url of the website to move.

.INPUTS
	System.String

.OUTPUTS
	System.Uri

.EXAMPLE
	PS C:\> Get-CleanSPUrl -Url "http://sharepoint.domain.ch/Projekte/SitePages/Homepage.aspx"
#>

	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Url
	)
    	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # cast as uri
    [Uri]$Url = $Url
  	
    # check if its a list or an library
	if($Url -match "(/Forms/).*?\.(aspx$)"){
    
        # its a library
        
        [Uri]$ListUrl =  $Url.AbsoluteUri -replace "(/Forms/).*?\.(aspx)",""
        [Uri]$WebUrl = $Url.AbsoluteUri -replace "/([^/]*)(/Forms/).*?\.(aspx)",""
        
        @{ListUrl=$ListUrl;WebUrl=$Weburl}
        
    }elseif($Url -match "(/Lists/).*?\.(aspx$)"){
    
        # its a list
        
        [Uri]$ListUrl =  $Url.AbsoluteUri -replace "/([^/]*)\.(aspx)",""
        [Uri]$WebUrl = $Url.AbsoluteUri -replace "(/Lists/).*?\.(aspx)",""
        
        @{ListUrl=$ListUrl;WebUrl=$Weburl}
        
    }elseif($Url -match "/SitePages/Homepage.aspx$" -or $Url -match "/default.aspx$"){
        
        # its a website
        
        [uri]$WebUrl = $Url -replace "/SitePages/Homepage.aspx", "" -replace "/default.aspx",""
        
        @{WebUrl=$Weburl}
         
	}else{        
		 @{WebUrl=$Url}
	}
}
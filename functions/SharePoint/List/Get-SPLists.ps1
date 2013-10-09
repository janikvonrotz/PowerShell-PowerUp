<#
$Metadata = @{
    Title = "Get SharePoint Lists"
	Filename = "Get-SPLists.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-29"
	LastEditDate = "2013-09-25"
	Version = "2.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPLists{

<#

.SYNOPSIS
    Get all SharePoint lists.

.DESCRIPTION
	Get all SharePoint lists.
    
.PARAMETER Url
	Url of the SharePoint website containing the lists.
    
.PARAMETER OnlyDocumentLibraries
	Only get document libraries
    
.PARAMETER Recursive
	Requires Identity, includes the every sub list of the specified website.


.EXAMPLE
	PS C:\> Get-SPLists -Url "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -OnlyDocumentLibraries -Recursive

#>

	param(
		[Parameter(Mandatory=$false)]
		[string]$Url,
        
        [Parameter(Mandatory=$false)]
		[string]$FilterListName,
		
		[switch]$OnlyDocumentLibraries,

		[switch]$Recursive
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
        Add-PSSnapin “Microsoft.SharePoint.PowerShell”
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
        
    $(if($Url){
    
        [Uri]$SPWebUrl = (Get-CleanSPUrl $Url).WebUrl
                
        if($Recursive){
               
            Get-SPWebs -Url $SPWebUrl.OriginalString 
                                   
        }else{
               
            Get-SPWeb -Identity $SPWebUrl.OriginalString
        }      
     }else{
     
        Get-SPWebs  
             
    }) | %{
    
        $_.lists | %{
            
            $(if($FilterListName){
            
                $_ | where{$_.Title -eq $FilterListName}
                
            }else{
            
                $_
            
            }) | %{
                      
                $(if($OnlyDocumentLibraries){
                
                    $_ | where {$_.BaseType -eq "DocumentLibrary"}
                    
                }else{
                
                    $_
                })
            }
        }
    }
}
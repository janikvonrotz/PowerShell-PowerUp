<#
$Metadata = @{
    Title = "Get SharePoint List"
	Filename = "Get-SPList.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function, get, list, library"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-20"
	LastEditDate = "2013-01-20"
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPList{

<#
.SYNOPSIS
    Get SharePoint list object

.DESCRIPTION
	Get SharePoint list object by providing one or more urls.
    
.PARAMETER Url
	Url to the SharePoint list.
    
.EXAMPLE
	PS C:\> Get-SPLists -Url "http://sharepoint.domain.ch/Site/Subsite/Lists/ListName/ListView.aspx"
#>

	param(
		[Parameter(Mandatory=$true)]
		[String[]]$Url
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin “Microsoft.SharePoint.PowerShell”}

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $Url | %{
    
        Get-SPUrl $_ | %{
        
            $ListName = ([Uri]$_.Url).LocalPath -replace ".*/",""
     
            Get-SPWeb $_.WebUrl | %{
            
                $_.Lists | where{$_.Title -eq $ListName}            
            }        
        }    
    }
}
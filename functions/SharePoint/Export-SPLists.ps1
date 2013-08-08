<#
$Metadata = @{
	Title = "Export SharePoint Lists"
	Filename = "Export-SPLists.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-09"
	LastEditDate = "2013-08-08"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Export-SPLists{

<#
.DESCRIPTION
	Export multiple SharePoint lists.

.PARAMETER  Urls
	A set of SharePoint list urls to export.
	
.PARAMETER  Path
	Path of the export folder.

.EXAMPLE
	Export-SPLists -Urls "http://sharepoint.domain.ch/it/Support/Forms/AllItems.aspx" -Path "C:\temp\SharePointExport"
#>
	
	param(	
		[Parameter(Mandatory=$true)]
		[String[]]
		$Urls,
				
		[Parameter(Mandatory=$true)]
		[String]
		$Path
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
	
		
	
	foreach($UrlItem in $Urls){
    
        # cast as uri
        [Uri]$Url = $UrlItem
      	
        # check if its a list or an library
		if($Url -match "(/Forms/).*?\.(aspx$)"){
        
            # its a library
            [Uri]$ListUrl =  $Url.AbsoluteUri -replace "(/Forms/).*?\.(aspx)",""            
            [Uri]$WebUrl = $Url.AbsoluteUri -replace "/([^/]*)(/Forms/).*?\.(aspx)",""
            
        }elseif($Url -match "(/Lists/).*?\.(aspx$)"){
        
            # its a list
            [Uri]$ListUrl =  $Url.AbsoluteUri -replace "/([^/]*)\.(aspx)",""
            [Uri]$WebUrl = $Url.AbsoluteUri -replace "(/Lists/).*?\.(aspx)",""
        }else{
            throw "Invalid Url: $UrlItem"
        }
        
        $SPWeb = Get-SPWeb -Identity $WebUrl.AbsoluteUri   	
		
		# check export path		
        if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
        
        $FileName = ($ListUrl.LocalPath -replace ".*/","")
        
        Write-Progress -Activity "Export SharePoint list" -status $FileName -percentComplete ([int]([array]::IndexOf($Urls, $UrlItem)/$Urls.Count*100))
		        
        # create export file
        $FilePath = Join-Path -Path $Path -ChildPath ( $FileName + "#" + $((get-date -format o) -replace ":","-") + ".bak")
        
		Export-SPWeb -Identity $SPWeb.Url -ItemUrl $ListUrl.LocalPath -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000

	}
}
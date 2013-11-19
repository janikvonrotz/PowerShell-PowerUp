<#
$Metadata = @{
	Title = "Export SharePoint List"
	Filename = "Export-SPList.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-08"
	LastEditDate = "2013-11-19"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Export-SPList{

<#
.DESCRIPTION
	Export a SharePoint list.

.PARAMETER  Url
	Url of the SharePoint list.

.PARAMETER  Path
	Provide a path for the temporary backup folder. Optional, default is c:\temp.

.PARAMETER  NoFileCompression
	Provide this parameter if the compressed list is oversized.
    
.OUTPUTS
	System.String

.EXAMPLE
	Export-SPLists -Url "http://sharepoint.domain.ch/it/Support/Forms/AllItems.aspx" -Path "C:\temp\SharePointExport" -NoFileCompression
    
.EXAMPLE
	Export-SPLists -Url "http://sharepoint.domain.ch/it/Support/Forms/AllItems.aspx" -Path "C:\temp\SharePointExport" -NoFileCompression
#>
	
	param(	
		[Parameter(Mandatory=$true)]
		[String]
		$ListUrl,
       			
		[Parameter(Mandatory=$false)]
		[String]
		$Path = "C:\temp",
        
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
    if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}   

    $SPUrl = Get-SPUrl $ListUrl     
    $SPWeb = Get-SPWeb $SPUrl.WebUrl 
          
    $FileName = ([uri]$SPUrl.Url).LocalPath -replace ".*/",""
    $FilePath = Join-Path -Path $Path -ChildPath ( $FileName + "#" + $((get-date -format o) -replace ":","-") + ".bak") 
       
    Write-Host "Export SharePoint list $FileName to $FilePath"    
    Export-SPWeb -Identity $SPWeb.Url -ItemUrl ([uri]$SPUrl.Url).LocalPath -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -NoFileCompression:$NoFileCompression
    
    $FilePath
}
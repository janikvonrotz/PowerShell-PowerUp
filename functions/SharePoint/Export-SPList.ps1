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
	LastEditDate = "2013-10-08"
	Version = "1.0.0"
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

.PARAMETER  Urls
	Url of the SharePoint list. Returns the filepath.
	
.PARAMETER  Path
	Provide a path for the temporary backup folder. Optional, default is c:\temp.
    
.OUTPUTS
	System.String

.EXAMPLE
	Export-SPLists -Urs "http://sharepoint.domain.ch/it/Support/Forms/AllItems.aspx" -Path "C:\temp\SharePointExport"
#>
	
	param(	
		[Parameter(Mandatory=$true)]
		[String]
		$Url,
				
		[Parameter(Mandatory=$false)]
		[String]
		$Path = "C:\temp",
        
        [Switch]
        $NoFileCompression
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

    $SPUrl = Get-CleanSPUrl -Url $Url        
    
    $SPWeb = Get-SPWeb -Identity ($SPUrl.WebUrl.Scheme + "://" + $SPUrl.WebUrl.Host + $SPUrl.WebUrl.LocalPath)
	
    if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
    
    $FileName = ($SPUrl.ListUrl.LocalPath -replace ".*/","")
    
    $FilePath = Join-Path -Path $Path -ChildPath ( $FileName + "#" + $((get-date -format o) -replace ":","-") + ".bak")
    
    Write-Host "Export SharePoint list $FileName to $FilePath"    
    
    Export-SPWeb -Identity $SPWeb.Url -ItemUrl $SPUrl.ListUrl.LocalPath -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -NoFileCompression:$NoFileCompression
    
    $FilePath	
}
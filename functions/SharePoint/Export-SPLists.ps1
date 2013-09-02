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
	LastEditDate = "2013-09-02"
	Version = "2.0.0"
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
	A set of SharePoint list urls to export. Returns the filepath for each export.
	
.PARAMETER  Path
	Provide a path for the temporary backup folder. Optional, default is c:\temp.
    
.OUTPUTS
	System.String

.EXAMPLE
	Export-SPLists -Urls "http://sharepoint.domain.ch/it/Support/Forms/AllItems.aspx" -Path "C:\temp\SharePointExport"
#>
	
	param(	
		[Parameter(Mandatory=$true)]
		[String[]]
		$Urls,
				
		[Parameter(Mandatory=$false)]
		[String]
		$Path = "C:\temp"
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
        $Url = Get-CleanSPUrl -Url $UrlItem        
        
        $SPWeb = Get-SPWeb -Identity ($Url.WebUrl.Scheme + "://" + $Url.WebUrl.Host + $Url.WebUrl.LocalPath)
		
		# check export path		
        if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
        
        $FileName = ($Url.ListUrl.LocalPath -replace ".*/","")
        
        Write-Progress -Activity "Export SharePoint list" -status $FileName -percentComplete ([int]([array]::IndexOf($Urls, $UrlItem)/$Urls.Count*100))
		        
        # create export file
        $FilePath = Join-Path -Path $Path -ChildPath ( $FileName + "#" + $((get-date -format o) -replace ":","-") + ".bak")
        
		Export-SPWeb -Identity $SPWeb.Url -ItemUrl $Url.ListUrl.LocalPath -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
        
        $FilePath

	}
}

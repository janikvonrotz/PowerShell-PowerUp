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
	LastEditDate = "2013-06-09"
	Version = "1.0.0"
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
	
	    $SPSites = $SPWebApp | Get-SPsite -Limit all 

    foreach($SPSite in $SPSites){

        $SPWebs = $SPSite | Get-SPWeb -Limit all
        
        foreach ($SPWeb in $SPWebs){

            $SPLists = $SPWeb | foreach{$_.Lists}

            foreach($SPList in $SPLists){
                
                Write-Progress -Activity "Backup SharePoint lists" -status $SPList.title -percentComplete ([int]([array]::IndexOf($SPLists, $SPList)/$SPLists.Count*100))
                
                $RelativePath = $SPSite.HostName + $SPList.RootFolder.ServerRelativeUrl.Replace("/","\")
                $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath

                if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

                $FileName = $SPList.Title + "#" + $(Get-LogStamp) + ".bak"
                $FilePath = Join-Path -Path $BackupPath -ChildPath $FileName
                
                Export-SPWeb -Identity $SPList.ParentWeb.Url -ItemUrl $SPList.RootFolder.ServerRelativeUrl -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
            }
        }
    }
	
	
	foreach($Url in $Urls){
	
		
	
		Write-Progress -Activity "Export SharePoint list" -status $SPList.title -percentComplete ([int]([array]::IndexOf($SPLists, $SPList)/$SPLists.Count*100))
		
		# check export path
		if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}
		

	}
}

<#
$Metadata = @{
  Title = "Backup All SharePont Lists"
	Filename = "Backup-AllSPLists.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, backup"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-14"
	LastEditDate = "2014-03-06"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-AllSPLists{

<#
.SYNOPSIS
	Export all sharepoint lists.

.DESCRIPTION
	Export all lists for every sharepoint webapplication into subfolders.

.PARAMETER  Path
	Path to the backup folders.

.EXAMPLE
	PS C:\> Backup-AllSPlists -Path "C:\Backup"

.INPUTS
	System.String
#>

	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[String]
		$Path
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#	
	if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Ignore)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
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
                
                $RelativePath = $SPSite.HostName + "\" + $SPList.RootFolder.ServerRelativeUrl.Replace("/","\")
                $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath

                if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

                $FileName = $SPList.Title + "#" + $((Get-Date -Format s) -replace ":","-") + ".bak"
                $FilePath = Join-Path -Path $BackupPath -ChildPath $FileName
                
                Export-SPWeb -Identity $SPList.ParentWeb.Url -ItemUrl $SPList.RootFolder.ServerRelativeUrl -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
            }
        }
    }
}
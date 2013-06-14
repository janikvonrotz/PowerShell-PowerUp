<#
$Metadata = @{
  Title = "Backup All SharePont Lists"
	Filename = "Backup-AllSPlists"
	Description = ""
	Tags = "powershell, sharepoint, function, backup"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-14"
	LastEditDate = "2013-06-14"
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-AllSPlists{

<#
.SYNOPSIS
	Export all sharepoint lists.

.DESCRIPTION
	Export all lists for every sharepoint webapplication in to backup folder.

.PARAMETER  Path
	Path to the backp folder.

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
	if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
	{
		Add-PSSnapin "Microsoft.SharePoint.PowerShell"
	}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#	
    $SPSites = $SPWebApp | Get-SPsite -Limit all 

    foreach($SPSite in $SPSites){

        [Uri]$SPSiteUrl = $SPSite.Url

        $SPWebs = $SPSite | Get-SPWeb -Limit all
        
        foreach ($SPWeb in $SPWebs){

            $SPLists = $SPWeb | foreach{$_.Lists}

            foreach($SPList in $SPLists){
                
                Write-Progress -Activity "Backup SharePoint Lists" -status $SPList.title -percentComplete ([int]([array]::IndexOf($SPLists, $SPList)/$SPLists.Count*100))
                
                $BackupPath = $Path + "\" + $SPSiteUrl.Authority + $SPList.RootFolder.ServerRelativeUrl.Replace("/","\")

                if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

                $FilePath = $BackupPath + "\" + $SPList.Title + "#" + $(Get-LogStamp) + ".bak"
                
                Export-SPWeb -Identity $SPList.ParentWeb.Url -ItemUrl $SPList.RootFolder.ServerRelativeUrl -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
            }
        }
    }
}
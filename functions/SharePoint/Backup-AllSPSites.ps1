<#
$Metadata = @{
  Title = "Backup All SharePont Sites"
	Filename = "Backup-AllSPSites.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, backup"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-17"
	LastEditDate = "2013-06-17"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-AllSPSites{

<#
.SYNOPSIS
	Export all sharepoint sites.

.DESCRIPTION
	Export all sites for every sharepoint webapplication in to backup folder.

.PARAMETER  Path
	Path to the backp folder.

.EXAMPLE
	PS C:\> Backup-AllSPWebs -Path "C:\Backup"

.INPUTS
	System.String
	
.LINK
	http://technet.microsoft.com/de-de/library/ff607901.aspx
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
			
		Write-Progress -Activity "Backup SharePoint sites" -status $SPSite.title -percentComplete ([int]([array]::IndexOf($SPSites, $SPSite)/$SPSites.Count*100))

		$FileName = $SPSite.title + "#" + $(Get-LogStamp) + ".bak"
		$FilePath = Join-Path $Path 
		
		if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}
		
        [Uri]$SPSiteUrl = $SPSite.Url

        $SPWebs = $SPSite | Get-SPWeb -Limit all
        
        foreach ($SPWeb in $SPWebs){

            Write-Progress -Activity "Backup SharePoint Lists" -status $SPWeb.title -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
                
                $BackupPath = $Path + "\" + $SPSiteUrl.Authority + $SPWeb.RootFolder.ServerRelativeUrl.Replace("/","\").TrimEnd("\")

                

                
                Export-SPWeb -Identity $SPWeb.Url -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
        }
    }
}
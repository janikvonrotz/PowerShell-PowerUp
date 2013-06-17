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

    if(!(Test-Path -path $Path)){New-Item $Path -Type Directory}

    foreach($SPSite in $SPSites){
			
		Write-Progress -Activity "Backup SharePoint sites" -status $SPSite.HostName -percentComplete ([int]([array]::IndexOf($SPSites, $SPSite)/$SPSites.Count*100))

		$FileName = $SPSite.HostName + "#" + $(Get-LogStamp) + ".bak"
		$FilePath = Join-Path -Path $Path -ChildPath $FileName
		
		Backup-SPSite -Identity $SPSite.Url -Path $FilePath -Force		
    }
}
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
	LastEditDate = "2013-06-26"
	Version = "1.0.1"
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
	Export all sites for every sharepoint webapplication into a subfolder.

.PARAMETER  Path
	Path to the backip folders.

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
        
        # set backup path
        $RelativePath = $SPSite.HostName
        $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath

        # create path if doesn't exist
        if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

        # set full path to backup file
		$FileName = $SPSite.HostName + "#" + $(Get-LogStamp) + ".bak"
		$FilePath = Join-Path -Path $BackupPath -ChildPath $FileName
		
		Backup-SPSite -Identity $SPSite.Url -Path $FilePath -Force		
    }
}
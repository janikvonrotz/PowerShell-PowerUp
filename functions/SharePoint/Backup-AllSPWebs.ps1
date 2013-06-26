<#
$Metadata = @{
  Title = "Backup All SharePont Websites"
	Filename = "Backup-AllSPWebs.ps1"
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

function Backup-AllSPWebs{

<#
.SYNOPSIS
	Export all sharepoint websites.

.DESCRIPTION
	Export all website for every sharepoint webapplication in to backup folder.

.PARAMETER  Path
	Path to the backp folder.

.EXAMPLE
	PS C:\> Backup-AllSPWebs -Path "C:\Backup"

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

        $SPWebs = $SPSite | Get-SPWeb -Limit all
        
        foreach ($SPWeb in $SPWebs){

            Write-Progress -Activity "Backup SharePoint websites" -status $SPWeb.title -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
                
            $RelativePath =  $SPSite.HostName + "\" + $SPWeb.Title + $SPWeb.RootFolder.ServerRelativeUrl.Replace("/","\").TrimEnd("\")
            $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath

            if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

            $FileName = $SPWeb.Title + "#" + $(Get-LogStamp) + ".bak"
            $FilePath = Join-Path $BackupPath -ChildPath $FileName
                
            Export-SPWeb -Identity $SPWeb.Url -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
        }
    }
}

Backup-AllSpwebs -Path "E:\SharePoint\Backup"
<#
$Metadata = @{
  Title = "Backup All SharePont Lists Uncompressed"
	Filename = "Backup-AllSPListsUncompressed.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, backup"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-14"
	LastEditDate = "2013-06-17"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-AllSPListsUncompressed{

<#
.SYNOPSIS
	Export all sharepoint lists.

.DESCRIPTION
	Export all lists for every sharepoint webapplication in to backup folder and returns the folders containing the backups for aditional PowerShell processing

.PARAMETER  Path
	Path to the backp folder.

.EXAMPLE
	PS C:\> $BackupFolders = Backup-AllSPlists -Path "C:\Backup"

.INPUTS
	System.String
    
.Output
	String Array
#>

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
    $BackupPaths = @()
    
    $SPSites = $SPWebApp | Get-SPsite -Limit all 

    foreach($SPSite in $SPSites){

        $SPWebs = $SPSite | Get-SPWeb -Limit all
        
        foreach ($SPWeb in $SPWebs){

            $SPLists = $SPWeb | foreach{$_.Lists}

            foreach($SPList in $SPLists){              
                
                Write-Progress -Activity "Backup SharePoint lists" -status $SPList.title -percentComplete ([int]([array]::IndexOf($SPLists, $SPList)/$SPLists.Count*100))
                
                $RelativePath = $SPSite.HostName + $SPList.RootFolder.ServerRelativeUrl.Replace("/","\")
                $BackupPaths += $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath
                              

                if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory  | Out-Null}

                $FileName = $SPList.Title + "#" + $(Get-LogStamp) + ".bak"
                $FilePath = Join-Path -Path $BackupPath -ChildPath $FileName
                
                Export-SPWeb -Identity $SPList.ParentWeb.Url -ItemUrl $SPList.RootFolder.ServerRelativeUrl -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoFileCompression
                
                $x += 1;
                if($x -eq 5){break}
            }if($x -eq 5){break}
        }if($x -eq 5){break}
    }if($x -eq 5){$BackupPaths; break}
}
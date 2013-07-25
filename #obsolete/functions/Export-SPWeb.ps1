<#
$Metadata = @{
  Title = "Export SharePoint Website"
	Filename = "Export-SPWeb.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, export"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-04"
	LastEditDate = "2013-07-04"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-Export-SPWeb{

<#
.SYNOPSIS
	Export a SharePoint website.

.DESCRIPTION
	Export a SharePoint website.

.PARAMETER Identity
	Url of the SharePoint website.
	
.PARAMETER  Path
	Path to the backup folders.

.EXAMPLE
	PS C:\> Export-SPWeb -Identity http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx -Path C:\Backup

#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Identity,
		
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

            Write-Progress -Activity "Backup SharePoint websites" -status $SPWeb.title -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
                
            $RelativePath =  $SPSite.HostName + "\" + $SPWeb.RootFolder.ServerRelativeUrl.Replace("/","\").TrimEnd("\")
            $BackupPath = Join-Path -Path $Path -ChildPath $RelativePath

            if(!(Test-Path -path $BackupPath)){New-Item $BackupPath -Type Directory}

            $FileName = $SPWeb.Title + "#" + $(Get-LogStamp) + ".bak"
            $FilePath = Join-Path $BackupPath -ChildPath $FileName
                
            Export-SPWeb -Identity $SPWeb.Url -Path $FilePath  -IncludeVersions All -IncludeUserSecurity -Force -NoLogFile -CompressionSize 1000
                
        }
    }
}
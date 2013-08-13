<#
$Metadata = @{
  Title = "Import SharePoint Website"
	Filename = "Import-JrSPWeb.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, import"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-04"
	LastEditDate = "2013-08-05"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Import-JrSPWeb{

<#
.SYNOPSIS
	Import a SharePoint website.

.DESCRIPTION
	Imort a SharePoint website into an existing website or a new one (requires Template parameter).

.PARAMETER Url
	Url of the SharePoint website to overwrite or create.
	
.PARAMETER  Path
	Path to the backup file.
	
.PARAMETER  Tempalte
	SharePoint website template, default is "STS#0".
    
.EXAMPLE
	PS C:\> Import-JrSPWeb -Url http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx -Path C:\Backup\SharePoint Superuser#2013-07-04 11-09-47.bak -Template "STS#1"

#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Url,
		
		[Parameter(Mandatory=$true)]
		[String]
		$Path,
                
		[Parameter(Mandatory=$false)]
		[String]
		$Template = "STS#0"
             
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
        
    # extract spweb url
    $SPWebUrl = $(Get-CleanSPUrl -Url $Url).WebUrl
    
    # get spweb object
    $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString -ErrorAction SilentlyContinue
    
    # if destination exists
    if(!$Error[0].FullyQualifiedErrorId -eq "Microsoft.SharePoint.PowerShell.SPCmdletGetWeb"){
    
        # import spweb
        Import-SPWeb $SPWeb.Url -Path $Path  -UpdateVersions Overwrite -Force -IncludeUserSecurity -NoFileCompression -NoLogFile -Confirm
    
    # if destination not exists
    }else{
                    
        # create a new site
        New-SPWeb ($SPWebUrl.OriginalString) -Template $Template
                
        # get new spweb object
        $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString       
        
        
        # delete list items on new site
        foreach ($SPList in $SPWeb.lists){
            $SPList.AllowDeletion = $true
            $SPList.delete()
            $SPList.Update() 
        }
                
        # import content
        Import-SPWeb $SPWeb.Url -Path $Path -UpdateVersions Overwrite -Force -IncludeUserSecurity -NoFileCompression -NoLogFile
        
        #>         
        
    }

    # finisher
    Write-Host "Finished" -ForegroundColor Green
    
}
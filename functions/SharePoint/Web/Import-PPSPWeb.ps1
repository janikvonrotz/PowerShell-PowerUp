<#
$Metadata = @{
  Title = "Import SharePoint Website"
	Filename = "Import-PPSPWeb.ps1"
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

function Import-PPSPWeb{

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

.PARAMETER  NoFileCompression
	Provide this parameter if the compressed website is oversized.
    
.EXAMPLE
	PS C:\> Import-PPSPWeb -Url http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx -Path C:\Backup\SharePoint Superuser#2013-07-04 11-09-47.bak -Template "STS#1"

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
		$Template = "STS#0",
        
        
        [Switch]
        $NoFileCompression
             
	)
	
	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#	
	if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
        
    # extract spweb url
    $SPUrl = $(Get-SPUrl $Url).Url
    
    # get spweb object
    $SPWeb = Get-SPWeb -Identity $SPUrl -ErrorAction SilentlyContinue
    
    # if destination exists
    if($SPWeb){
    
        Import-SPWeb $SPWeb -Path $Path -UpdateVersions Overwrite -Force -IncludeUserSecurity -NoFileCompression:$NoFileCompression -NoLogFile -Confirm
    
    # if destination not exists
    }else{
                    
        # create a new site
        New-SPWeb -Url $SPUrl -Template (Get-SPWebTemplate $Template)
                
        # get new spweb object
        $SPWeb = Get-SPWeb -Identity $SPUrl       
        
        
        # delete list items on new site
        $spweb.Lists | %{
            $_.AllowDeletion = $true
            $_.Update() 
            $_.delete()
        }

        Import-SPWeb $SPWeb -Path $Path -UpdateVersions Overwrite -Force -IncludeUserSecurity -NoFileCompression:$NoFileCompression -NoLogFile -Confirm
    }

    Write-Host "Finished" -ForegroundColor Green    
}
$Metadata = @{
	Title = "Move SharePoint Lists"
	Filename = "Move-SPLists.ps1"
	Description = ""
	Tags = "powershell, sharepoint, lists"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-12"
	LastEditDate = "2013-03-13"
	Version = "0.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example
#--------------------------------------------------#

Move-SPLists -SPSourceWebUrl "http://sharepoint.vbl.ch/SitePages/Homepage.aspx" -SPDestWebUrl "http://sharepoint.vbl.ch/Direktion/Erweiterte%20Gesch%c3%a4ftsleitung/SitePages/Homepage.aspx" -SPLists "IT Architektur Board"

#>

function Move-SPLists{

    #--------------------------------------------------#
    # Parameter
    #--------------------------------------------------#
    param(
        [parameter(Mandatory=$true)]
        [String]
		$SPSourceWebUrl,
        [parameter(Mandatory=$true)]
        [String]
		$SPDestWebUrl,
        [parameter(Mandatory=$true)]
        [string[]] 
        $SPLists
    )
    

    #--------------------------------------------------#
    # Includes
    #--------------------------------------------------#
    # Import Modules
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    }
    
    #--------------------------------------------------#
    # Settings
    #--------------------------------------------------#
    # LoadConfig
    $LocalTempExportPath = "C:\temp\SharePointExport\"
    if (!(Test-Path -path $LocalTempExportPath)) {New-Item $LocalTempExportPath -Type Directory}
    $SPListFileExtension = $(Get-LogStamp) + ".cmp"
    $SPListPath ="/Lists/"

    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#
    
    #Clean up
    $SPSourceWeburl = Clean-Url $SPSourceWeburl
    $SPDestWebUrl = Clean-Url $SPDestWebUrl
    $SPSourceWeburl = $SPSourceWeburl -replace "/SitePages/Homepage.aspx", ""
    $SPDestWebUrl = $SPDestWebUrl -replace "/SitePages/Homepage.aspx", ""
    
    
    foreach($SPList in $SPLists){
        Write-Host ("`nExporting " + $SPSourceWebUrl + $SPListPath + $SPList) -BackgroundColor Yellow -ForegroundColor Black
        
        #Export the list
        Export-SPWeb ($SPSourceWebUrl) -ItemUrl ($SPListPath +  $SPList) -IncludeUserSecurity -IncludeVersions All -path ($LocalTempExportPath + $SPList + $SPListFileExtension) -nologfile -Force
        
        Write-Host ("`nExporting complete") -BackgroundColor Green -ForegroundColor Black

        Write-Host ("`nImporting " + $SPDestWebUrl + $SPListPath + $SPList) -BackgroundColor Yellow -ForegroundColor Black
        
        #Import the list
        Import-spweb $SPDestWebUrl -IncludeUserSecurity -path ($LocalTempExportPath + $SPList + $SPListFileExtension) -nologfile -Force
        
        Write-Host ("`nImporting complete") -BackgroundColor Green -ForegroundColor Black

        #Ask wether to delte the source list or not
        $Choice = Read-Host "`nDelete the Source Lists (y/n)?"
        if($Choice -eq "y"){
            $SPWeb = Get-SPWeb -Identity $SPSourceWebUrl
            $SPList = $SPWeb.lists[$SPList]
            $SPList.AllowDeletion = $true
            $SPList.Update()
            $SPList.Delete()
            Write-Host ("`nList deleted")  -BackgroundColor Yellow -ForegroundColor Black

        }
    }
}
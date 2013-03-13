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

Move-SPLists -SPSourceWebUrl http://server.SharePoint.Com/Sub1 -SPDestWebUrl http://server.SharePoint.com/Sub1/forums -SPLists "List Number 1", "List Number 2"

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
    # Settings
    #--------------------------------------------------#
    # LoadConfig
    $LocalTempExportPath = "C:\temp\SharePointExport\"
    $SPListFileExtension = ".cmp"

    #--------------------------------------------------#
    # Includes
    #--------------------------------------------------#
    # Import Modules
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Add-PSSnapin "Microsoft.SharePoint.PowerShell"


        #--------------------------------------------------#
        # Main
        #--------------------------------------------------#
        foreach($List in $SPLists){
            Write-Host ("`nExporting " + $SPSourceWebUrl + "/lists/" + $List) -BackgroundColor Yellow -ForegroundColor Black
            Export-spweb $SPSourceWebUrl -ItemUrl ("lists/" + $List) -IncludeUserSecurity -IncludeVersions All -path ($LocalTempExportPath + $List + $SPListFileExtension) -nologfile
            Write-Host ("`nExporting complete") -BackgroundColor Green -ForegroundColor DarkGreen

            Write-Host ("`nExporting " + $SPSourceWebUrl + "/lists/" + $List) -BackgroundColor Yellow -ForegroundColor Black
            Import-spweb $SPDestWebUrl -IncludeUserSecurity -path ($LocalTempExportPath + $List + $SPListFileExtension) -nologfile
            Write-Host ("`nImporting complete") -BackgroundColor Green -ForegroundColor DarkGreen

            $Choice = Read-Host "Delete the Source Lists (y/n)?"

            $SPWeb = Get-SPWeb -Identity SPSourceWebUrl
            $SPList = $web.lists[$List]
            $SPList.AllowDeletion = $true
            $SPList.Update()
            $SPList.Delete()
        }
    }else{
        throw "Microsoft.SharePoint.PowerShell not available"
    }
}
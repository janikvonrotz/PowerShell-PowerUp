$Metadata = @{
	Title = "Move SharePoint Objects"
	Filename = "Move-SPobjects.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-12"
	LastEditDate = "2013-04-02"
	Version = "1.0.1"
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

Move-SPobjects -SPSourceWebUrl "http://sharepoint.vbl.ch/SitePages/Homepage.aspx" -SPDestWebUrl "http://sharepoint.vbl.ch/Direktion/Erweiterte%20Gesch%c3%a4ftsleitung/SitePages/Homepage.aspx" -SPLists "IT Architektur Board"

Move-SPobjects -SPSourceWebUrl "http://sharepoint.vbl.ch/finanzen/it/Abteilungssite/SitePages/Homepage.aspx" -SPDestWebUrl "http://sharepoint.vbl.ch/Direktion/Erweiterte%20Gesch%c3%a4ftsleitung/SitePages/Homepage.aspx" -SPLibs "Abteilung"

#>

function Move-SPobjects{

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
        [parameter(Mandatory=$false)]
        [string[]] 
        $SPLists,
        [parameter(Mandatory=$false)]
        [string[]] 
        $SPLibs
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
	
    $SPFileExtension = $(Get-LogStamp) + ".cmp"
	
    $SPListPath ="/Lists/"
    

    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#
    
    #Uri encoding
    $SPSharePointUrl = ([System.Uri]$SPSourceWeburl).Host
    $SPSharePointUrl = "http://" +  $SPSharePointUrl
     
    $SPSourceWeburl = ([System.Uri]$SPSourceWeburl).LocalPath
    $SPDestWebUrl = ([System.Uri]$SPDestWebUrl).LocalPath
    
	#Replace apendix for absolute path
    $SPSourceWeburl = $SPSourceWeburl -replace "/SitePages/Homepage.aspx", ""
    $SPDestWebUrl = $SPDestWebUrl -replace "/SitePages/Homepage.aspx", ""
	
    $SPSourceWeburl = $SPSourceWeburl -replace $SPSharePointUrl, ""
    
    if($SPLists -ne $Null){
        foreach($SPList in $SPLists){
            Write-Host ("`nExporting " + $SPSharePointUrl + $SPSourceWebUrl + $SPListPath + $SPList) -BackgroundColor Yellow -ForegroundColor Black        
            #Export the list
            Export-SPWeb ($SPSharePointUrl + $SPSourceWebUrl) -ItemUrl ($SPSourceWebUrl + $SPListPath +  $SPList) -IncludeUserSecurity -IncludeVersions All -path ($LocalTempExportPath + $SPList + $SPFileExtension) -nologfile -Force

            Write-Host ("`nImporting " + $SPSharePointUrl  + $SPDestWebUrl + $SPListPath + $SPList) -BackgroundColor Yellow -ForegroundColor Black        
            #Import the list
            Import-spweb ($SPSharePointUrl + $SPDestWebUrl) -IncludeUserSecurity -path ($LocalTempExportPath + $SPList + $SPFileExtension) -nologfile -Force

            #Ask wether to delte the source list or not
            $Choice = Read-Host "`nDelete the Source Lists (y/n)?"
            if($Choice -eq "y"){
                $SPWeb = Get-SPWeb -Identity ($SPSharePointUrl + $SPSourceWeburl)
                $SPList = $SPWeb.lists[$SPList]
                $SPList.AllowDeletion = $true
                $SPList.Update()
                $SPList.Delete()
                Write-Host ("`nList deleted")  -BackgroundColor Yellow -ForegroundColor Black

            }
        }
    }

    if($SPLibs -ne $Null){	
    	foreach($SPLib in $SPLibs){
            Write-Host ("`nExporting " + $SPSharePointUrl + $SPSourceWebUrl + "/" + $SPLib) -BackgroundColor Yellow -ForegroundColor Black        
            #Export the list
            Export-SPWeb ($SPSharePointUrl + $SPSourceWebUrl) -ItemUrl ($SPSourceWebUrl + "/" + $SPLib) -IncludeUserSecurity -IncludeVersions All -path ($LocalTempExportPath + $SPLib + $SPFileExtension) -nologfile -Force

            Write-Host ("`nImporting " + $SPSharePointUrl  + $SPDestWebUrl + "/" + $SPLib) -BackgroundColor Yellow -ForegroundColor Black        
            #Import the list
            Import-spweb ($SPSharePointUrl + $SPDestWebUrl) -IncludeUserSecurity -path ($LocalTempExportPath + $SPLib + $SPFileExtension) -nologfile -Force

            #Ask wether to delte the source list or not
            $Choice = Read-Host "`nDelete the Source Lists (y/n)?"
            if($Choice -eq "y"){
                $SPWeb = Get-SPWeb -Identity ($SPSharePointUrl + $SPSourceWeburl)
                $SPList = $SPWeb.lists[$SPLib]
                $SPList.AllowDeletion = $true
                $SPList.Update()
                $SPList.Delete()
                Write-Host ("`nList deleted")  -BackgroundColor Yellow -ForegroundColor Black

            }
        }
    }
}


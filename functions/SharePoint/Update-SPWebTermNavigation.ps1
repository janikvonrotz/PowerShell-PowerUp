<#
$Metadata = @{
	Title = "Update SharePoint Web Term Navigation"
	Filename = "Update-SPWebTermNavigation.ps1"
	Description = ""
	Tags = "sharepoint, managed, metadata, navigation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-05-09"
	LastEditDate = "2014-05-09"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Update-SPWebTermNavigation{

<#
.SYNOPSIS
    Update the term based navigation for a speific SharePoint website.

.DESCRIPTION
    Update the term based navigation for a speific SharePoint website.

.PARAMETER Identity
	Url of the website.

.PARAMETER MMSSite
	Managed metadata site.

.PARAMETER TermStoreName
	Name of the term store that holds the navigation term groups.

.PARAMETER TermGroupName
	Name of the term group that holds the navigation term sets.

.PARAMETER TermSetName
	Name of the term set that hold the navigation terms for this website.

.PARAMETER GlobalNavigationTermGroupName
	Name of the term group that holds the global navigation term set. Only required if this is different from the term group name.

.PARAMETER GlobalNavigationTermSetName
	Name of the global term set where the terms should be pinned from.

.EXAMPLE
	PS C:\> Update-SPWebTermNavigation -Identity "http://SiteXY.example.org" -MMSSite "http://sharepoint.example.org" -TermStoreName "Store1" -TermGroupName "Navigation" -TermSetName "SiteXY" -GlobalNavigationTermSetName "GlobalNavigation"

.EXAMPLE
	PS C:\> Update-SPWebTermNavigation -Identity "http://SiteXY.example.org" -MMSSite "http://sharepoint.example.org" -TermStoreName "Store1" -TermGroupName "Navigation" -TermSetName "SiteXY" -GlobalNavigationTermGroupName "AnotherNavigation" -GlobalNavigationTermSetName "GlobalNavigation"

#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true)]
        [String]$Identity,

        [Parameter(Mandatory=$true)]
        [String]$MMSSite,
        
        [Parameter(Mandatory=$true)]
        [String]$TermStoreName,
        
        [Parameter(Mandatory=$true)]
        [String]$TermGroupName,
        
        [Parameter(Mandatory=$true)]
        [String]$TermSetName,
        
        [Parameter(Mandatory=$false)]
        [String]$GlobalNavigationTermGroupName,

        [Parameter(Mandatory=$true)]
        [String]$GlobalNavigationTermSetName
    )

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#

    if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
      
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    Write-Host "Update term navigation settings for: $Identity"

    # get website and site collection
    $SPWeb = Get-SPWeb $Identity
    $SPSite = $SPWeb.Site

    # get the navigation settings
    $WebNavigationSettings = New-Object Microsoft.SharePoint.Publishing.Navigation.WebNavigationSettings($SPWeb)

    # get the navigation term set
    $SPTaxonomySession = Get-SPTaxonomySession -Site $MMSSite
    $TermStore = $SPTaxonomySession.TermStores[$TermStoreName]
    $TermGroup = $TermStore.Groups[$TermGroupName]
    $TermSet = $TermGroup.TermSets[$TermSetName]

    # get the global navigation term set
    if($GlobalNavigationTermGroupName){
        $GlobalNavigationTermGroup = $TermStore.Groups[$GlobalNavigationTermGroupName]
        $GlobalNavigationTermSet = $GlobalNavigationTermGroup.TermSets[$GlobalNavigationTermSetName]
    }else{
        $GlobalNavigationTermSet = $TermGroup.TermSets[$GlobalNavigationTermSetName]
    }

    # remove all the existing terms
    $TermSet.Terms | ForEach-Object{$_.delete()}
    $TermStore.CommitAll()

     # pin the terms from the master term set
     $GlobalNavigationTermSet.Terms | ForEach-Object{$TermSet.ReuseTermWithPinning($_) | Out-Null}

     # copy the sort order
     $TermSet.CustomSortOrder = $GlobalNavigationTermSet.CustomSortOrder 
     $TermStore.CommitAll()

     # update the navigation settings
     $WebNavigationSettings.GlobalNavigation.Source = 2
     $WebNavigationSettings.GlobalNavigation.TermStoreId = $TermStore.Id
     $WebNavigationSettings.GlobalNavigation.TermSetId = $TermSet.Id

     $WebNavigationSettings.AddNewPagesToNavigation = $false
     $WebNavigationSettings.CreateFriendlyUrlsForNewPages = $false
     $WebNavigationSettings.Update()
}

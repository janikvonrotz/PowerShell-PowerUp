<#
$Metadata = @{
	Title = "Get SharePoint Managed Metadata Service Terms"
	Filename = "Get-SPManagedMetadataServiceTerms.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint, managed, metadata, terms, export"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-03-31"
	LastEditDate = "2014-03-31"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPManagedMetadataServiceTerms{

<#
.SYNOPSIS
    List all Terms from Managed Metadata service.

.DESCRIPTION
	List all Terms form a specifified term store and optionally filter them by term group.

.PARAMETER Site
	Site running a taxonomy session.

.PARAMETER TermGroup
	Optionally filter the term group.

.EXAMPLE
	PS C:\> Get-SPManagedMetadataServiceTerms -Site "http://SharePoint.domain.com"

.EXAMPLE
	PS C:\> Get-SPManagedMetadataServiceTerms -Site "http://SharePoint.domain.com" -TermGroup "Wiki"

.LINK
    http://technet.microsoft.com/en-us/library/ee424396(v=office.14).aspx

#>

    [CmdletBinding()]
    param(

		[Parameter(Mandatory=$true)]
		[String]
		$Site,

		[String]
		$TermGroup
        
	)
    
    #--------------------------------------------------#
    # functions
    #--------------------------------------------------#

    function Add-ArrayLevelIndex{

        param(
    
            $Object,        
            $AttributeName,        
            $Level = 0
        )
    
        # check the child attribute containing the same type of objects
        $Objects = iex "`$Object.$AttributeName"
    
        # output this item
        $Object | select @{L="Object";E={$_}}, @{L="Level";E={$Level}}
    
        # output the child items of this object
        if($Objects){
    
            # add level
            $Level ++
        
            # loop trough the same function
            $Objects | %{Add-ArrayLevelIndex -Object $_ -AttributeName $AttributeName -Level $Level}

        }
    }

    #--------------------------------------------------#
    # modules
    #--------------------------------------------------# 
    if((Get-PSSnapin 'Microsoft.SharePoint.PowerShell' -ErrorAction SilentlyContinue) -eq $null){Add-PSSnapin 'Microsoft.SharePoint.PowerShell'}

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $SPTaxonomies = @()

    # get all taxonomy objects
    $SPTaxonomies = Get-SPTaxonomySession -Site $Site | %{

        $_.TermStores | %{
    
            $TermStore = New-Object -TypeName Psobject -Property @{
        
                TermStore = $_.Name
                "Term Group" = ""
                "Term Set Name" = ""
                "Term Set Description" = ""   
                LCID = ""             
                "Available for Tagging" = ""                
                Terms = ""      
            }        
        
        
            $_.Groups | Where{$_.Name -eq $TermGroup -or -not $TermGroup} | ForEach-Object{
            
                $Group = $TermStore.PSObject.Copy()
                $Group.'Term Group' = $_.Name                       
        
                $_.TermSets | %{
            
                    $TermSet = $Group.PSObject.Copy()
                    $TermSet.'Term Set Name' = $_.Name
                    $TermSet.'Term Set Description' = $_.Description
                                    
                    $TermSet.Terms = ($_.Terms | %{Add-ArrayLevelIndex -Object $_ -AttributeName "Terms" -Level 1})
            
                    $TermSet                  
                }        
            }        
        }
    }

    # get maximum of levels a term has
    # $Levels = ($SPTaxonomies | %{$_.Terms | %{$_.Level}} | measure -Maximum).Maximum + 1
    # or comment out and use default 7

    # loop throught term stores       
    $SPTaxonomies | %{

        $SPTaxonomy = $_
    
        # loop throught terms
        $_.Terms | %{
                
            $Term = $_

            # create a term export object
            $Item = $SPTaxonomy.PSObject.Copy()   
             
            $Item.'Available for Tagging' = if($_.IsAvailableForTagging){"TRUE"}else{"FALSE"}
            
            $_.Object.Labels | ForEach-Object{

                $Item.LCID = $_.Language

                $Index = 1;while($Index -ne 8){

                    if($Term.Level -eq $Index){

                        $Value = $Term.Object.Name

                    }else{
                            
                        $Value = ""
                    }

                    $Item | Add-Member –MemberType NoteProperty –Name "Level $Index Term" –Value $Value
           
                    $Index += 1
                }  
            }   
        
            # output this object
            $Item |  Select-Object 'Term Set Name','Term Set Description', LCID, 'Available for Tagging', 'Term Description', 'Level*'
        }                
    }
}
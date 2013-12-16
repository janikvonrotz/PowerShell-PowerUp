<#
$Metadata = @{
	Title = "Sync AD Group Members"
	Filename = "Sync-ADGroupMember.ps1"
	Description = ""
	Tags = "powershell, activedirectory, sync, group, members"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-11-11"
	LastEditDate = "2013-12-16"
	Url = ""
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Sync-ADGroupMember{

<#
.SYNOPSIS
    Advanced syncing of ad group members.

.DESCRIPTION
	Will update the members of and an ad group by comparing the already assigned members the members to assign provided by a parameter.

.PARAMETER  ADGroup
	Provide the ActiveDirectory group to update.

.PARAMETER  Member
	The members to assign.

.PARAMETER  LogScriptBlock
	Use the variable $Message variable inside the script block.
    Every sync action will update the $Message variable and run the report script block.

.EXAMPLE
	PS C:\> Sync-ADGroupMember -ADGroup "Group1" -Member "User1", "Group1", "User2" -LogScriptBlock {Write-Host $Message}

.EXAMPLE
	PS C:\> Sync-ADGroupMember -ADGroup $ADGroupObject -Member $ADGroupMemberObjects -LogScriptBlock {Write-Host $Message}

#>

	[CmdletBinding()]
	param(
    
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$ADGroup,
        
        [Parameter(Mandatory=$true)]
		[ValidateNotNull()]
        [System.Array]
		$Member,
        
        [Parameter(Mandatory=$false)]
		[ValidateNotNull()]
        [ScriptBlock]
		$LogScriptBlock,
        
        [switch]
        $OnlyAdd,
        
        [switch]
        $OnlyRemove
        
	)# param end
    
    #--------------------------------------------------#
	# modules
	#--------------------------------------------------#   
    Import-Module activedirectory
    
 	#--------------------------------------------------#
	# main
	#--------------------------------------------------#   
    $ADGroup | %{
    
        if($_.PsObject.TypeNames -notcontains "Microsoft.ActiveDirectory.Management.ADGroup"){
            $ADGroupItem = Get-ADGroup $_
        }else{
            $ADGroupItem = $_
        }
        
        if($Member[0].PsObject.TypeNames -notcontains "Microsoft.ActiveDirectory.Management.ADObject"){
            $Member = $($Member | %{
                Get-ADObject -Filter 'Name -eq $_' | 
                select -First 1 | %{
                    if($_.ObjectClass -eq "user"){
                        Get-ADUser $_.DistinguishedName
                    }elseif($_.ObjectClass -eq "group"){
                        Get-ADGroup $_.DistinguishedName
                    }
                }
            })
        }

        $IsMember = $(Get-ADGroupMember $ADGroupItem)
        if($IsMember){
            Compare-Object -ReferenceObject $IsMember -DifferenceObject $Member -Property Name, DistinguishedName | %{
            
                if($_.SideIndicator -eq "<=" -and -not $OnlyAdd){
                    
                    $Message = "Remove ADGroupMember: $($_.Name) from ADGroup: $($ADGroupItem.Name)"
                    Invoke-Command -ScriptBlock $LogScriptBlock
                    Remove-ADGroupMember -Identity $ADGroupItem -Members $_.DistinguishedName -Confirm:$false
                
                }elseif($_.SideIndicator -eq "=>" -and -not $OnlyRemove){
                
                    $Message = "Add ADGroupMember: $($_.Name) to ADGroup: $($ADGroupItem.Name)"
                    Invoke-Command -ScriptBlock $LogScriptBlock
                    Add-ADGroupMember -Identity $ADGroupItem -Members $_.DistinguishedName -Confirm:$false
                }
            }
        }elseif($Member){
            $Member | %{
            
                $Message = "Add ADGroupMember: $($_.Name) to ADGroup: $($ADGroupItem.Name)"
                Invoke-Command -ScriptBlock $LogScriptBlock
                Add-ADGroupMember -Identity $ADGroupItem -Members $_  -Confirm:$false
            }
        }       
    }
}# function end
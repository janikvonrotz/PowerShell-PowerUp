<#
$Metadata = @{
    Title = "Report ActiveDirectory User Groups"
	Filename = "Report-ActiveDirectoryUserGroups.ps1"
	Description = ""
	Tags = ""powershell, activedirectory, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-07-11"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Report-ActiveDirectoryUserGroups{

<#

.SYNOPSIS
    Report for specific user their member of groups.

.DESCRIPTION
	Report for specific user their member of groups.

.PARAMETER  Users
	Array of usernames to report

.EXAMPLE
	PS C:\> Report-ActiveDirectoryUserGroups - Users "user1","user2"

#>

    param(
        [parameter(Mandatory=$true)]
        [string[]]$Users
    )   

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	$ADUserGroupReport = @()
		
	foreach($User in $Users){
	   
        # get user AD objects
        $ADusers = Get-QADUser $User -Properties Name,DN,SamAccountName,MemberOf | Select-Object Name,DN,SamAccountName,MemberOf

        # cycle throught AD user collection
        foreach($ADUser in $ADusers){
            
			# add special user groups
			$ADUserGroups = Get-QADMemberOf $ADUser.SamAccountName -Indirect
            			
            # cycle through every parent group
			foreach($ADUserGroup in $ADUserGroups){ 
				
                Write-Progress -Activity "Collecting data" -status $ADUserGroup.Name -percentComplete ([int]([array]::IndexOf($ADUserGroups, $ADUserGroup)/$ADUserGroups.Count*100))

				$ADUserGroupReport += New-ADUseGroup -Name $ADUser.Name -DN $ADUser.DN -SamAccountName $ADUser.SamAccountName -GroupName $ADUserGroup.Name
              
			} 
		}
	}
    
    return $ADUserGroupReport
        	
}
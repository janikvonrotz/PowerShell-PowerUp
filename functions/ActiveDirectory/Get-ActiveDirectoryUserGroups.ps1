<#
$Metadata = @{
    Title = "Get ActiveDirectory User Groups"
	Filename = "Get-ActiveDirectoryUserGroups.ps1"
	Description = ""
	Tags = ""powershell, activedirectory, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-07-25"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-ActiveDirectoryUserGroups{

<#

.SYNOPSIS
    Report for specific user their member of groups.

.DESCRIPTION
	Report for specific user their member of groups.

.PARAMETER  Users
	Array of usernames to report

.EXAMPLE
	PS C:\> Get-ActiveDirectoryUserGroups - Users "user1","user2"

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

                New-ObjectADUserGroup -UserName $ADUser.Name -UserDN $ADUser.DN -UserSamAccountName $ADUser.SamAccountName -GroupName $ADUserGroup.Name -GroupDN $ADUserGroup.DN -GroupSamAccountName $ADUserGroup.SamAccountName
              
			} 
		}
	}    
}
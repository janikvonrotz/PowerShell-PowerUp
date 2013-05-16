param([switch]$OutPutToGridView,[parameter(Mandatory=$true)][string[]]$Usernames)

$Metadata = @{
	Title = "Report ActiveDirectory User Groups"
	Filename = "Report-ActiveDirectoryUserGroups.ps1"
	Description = ""
	Tags = "powershell, activedirectory, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-27"
	LastEditDate = "2013-05-16"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
.Example
    .\Report-ActiveDirectoryUserGroups.ps1 -OutPutToGridView -Usernames "User1", "User2"
    
.Example
    $Report = .\Report-ActiveDirectoryUserGroups.ps1 -Usernames "User1", "User2"
#>

if($Host.Version.Major -gt 2){
    throw "Only compatible with Powershell version 2 and less"
}else{

	#--------------------------------------------------#
	# includes
	#--------------------------------------------------#
	Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	$ADUserGroupReport = @()
	
	function New-ADReportItem {
		param(
			$Name,
			$DN,
			$SamAccountName,
			$GroupName
		)
		New-Object PSObject -Property @{
			Name = $Name
			DN = $DN
			SamAccountName = $SamAccountName
			GroupName =$GroupName
		}
	}
	
	foreach($Username in $Usernames){
	   
        # get user AD objects
        $ADusers = Get-QADUser $Username -Properties Name,DN,SamAccountName,MemberOf | Select-Object Name,DN,SamAccountName,MemberOf

        # cycle throught AD user collection
        foreach($ADUser in $ADusers){
            
			# add special user groups
			$ADUserGroups = Get-QADMemberOf $ADUser.SamAccountName -Indirect
            			
            # cycle through every parent group
			foreach($ADUserGroup in $ADUserGroups){ 
				
                Write-Progress -Activity "collecting data" -status $ADUserGroup.Name -percentComplete ([int]([array]::IndexOf($ADUserGroups, $ADUserGroup)/$ADUserGroups.Count*100))

				$ADUserGroupReport += New-ADReportItem -Name $ADUser.Name -DN $ADUser.DN -SamAccountName $ADUser.SamAccountName -GroupName $ADUserGroup.Name
              
			} 
		}
	}

	if($OutPutToGridView -eq $true){
    
		$ADUserGroupReport | Out-GridView
        
        Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green
        Read-Host "`nPress Enter to exit"

	}else{
    
		return $ADUserGroupReport
        
	}	
}
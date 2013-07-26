<#
$Metadata = @{
	Title = "PowerShell Object ActiveDirectory User Group"
	Filename = "Object-ADUserGroup.ps1"
	Description = ""
	Tags = "powershell, function, activedirectory, object"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-07-26"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function New-ObjectADUserGroup{
	param(
		$UserName,
		$UserDN,
		$UserSamAccountName,
		$GroupName,
        $GroupDN,
        $GroupSamAccountName
	)
	New-Object PSObject -Property @{
		UserName = $UserName
		UserDN = $UserDN
		UserSamAccountName = $UserSamAccountName
		GroupName = $GroupName
        GroupDN = $GroupDN
        GroupSamAccountName  = $GroupSamAccountName
	}
}
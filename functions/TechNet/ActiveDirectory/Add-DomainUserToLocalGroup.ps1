function Add-DomainUserToLocalGroup{

	[cmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)]
		[string]$computer,
		[Parameter(Mandatory=$True)]
		[string]$group,
		[Parameter(Mandatory=$True)]
		[string]$domain,
		[Parameter(Mandatory=$True)]
		[string]$user
	)
	
	$Group = [ADSI]"WinNT://$computer/$Group,group"
	$Group.psbase.Invoke("Add",([ADSI]"WinNT://$domain/$user").path)
}
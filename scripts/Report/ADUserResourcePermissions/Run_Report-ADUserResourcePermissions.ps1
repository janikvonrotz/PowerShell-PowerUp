param([Switch]$NoExit)
if($NoExit -eq $false){
	powershell -NoExit $MyInvocation.MyCommand.Definition -NoExit
	exit
}

.\Report-ADUserResourcePermissions.ps1 | Out-Gridview
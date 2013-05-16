param([Switch]$NoExit)
if($NoExit -eq $false){
	powershell -NoExit $MyInvocation.MyCommand.Definition -NoExit
	exit
}

While(1){

	.\Report-ADUserResourcePermissions.ps1 | Out-Gridview

	$Choice = Read-Host "`nNew Report? (y/n)"
	if($Choice -ne "y"){break}
	
}
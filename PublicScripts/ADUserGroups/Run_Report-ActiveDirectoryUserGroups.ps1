$Usernames = @()
While(1){
	$Username = Read-Host "Enter a username (or . to finish)}
	if($Username -eq "."){
		break;
	}else{
		$Usernames += $Username
	}
}
powershell ".\Report-ActiveDirectoryUserGroups.ps1" -OutPutToGridView -Usernames $Usernames
$Usernames = @()
$FirstEntry = $true

While(1){
	$Username = Read-Host "`nEnter a username (or . to finish)"
	if($Username -eq "."){
		break
	}elseif($FirstEntry -eq $true){
        $Usernames += $Username		
        $FirstEntry = $false
    }else{
        $Usernames += "," + $Username
    }
}
powershell ".\Report-ActiveDirectoryUserGroups.ps1" -OutPutToGridView -Usernames $Usernames
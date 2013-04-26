$s1 = rps sp1
$s2 = rps data1

$Report1 = Invoke-Command -Session $s1 -ScriptBlock {D:\Powershell-Profile\scripts\Report\Report-SPSecurableObjectPermissions.ps1}
$Report2 = Invoke-Command -Session $s2 -ScriptBlock {(C:\Powershell-Profile\scripts\Report\Report-FileSystemPermissions#NoDependencies.ps1 -Path "F:\Dat" -Levels 3)}

$GroupPermissionReports = $Report1 + $Report2

While(1){

	$Usernames = @()
    $Report = @()
    
	While(1){
		$Username = Read-Host "`nEnter a username (or . to finish)"
		if($Username -eq "."){
			break
		}else{
		$Usernames += $Username	
		}
	}
    
    foreach($username in $Usernames){
    
    	$UserGroups = .\Report-ActiveDirectoryUserGroups.ps1 -Usernames $Username
        
        foreach ($UserGroup in $UserGroups){
        
            $GroupPermissions = $Null
    	    $GroupPermissions = ($GroupPermissionReports | Where-Object {$_.Member -like $UserGroup.GroupName})
            
            if($GroupPermissions -ne $Null){
                foreach($GroupPermission in $GroupPermissions){

                    Add-Member -InputObject GroupPermission -MemberType NoteProperty -Name "Username" -Value $Username
                    
                    $Report += GroupPermission
                    
                }
            }
        }
    }
	$Report | Out-GridView

	$Choice = Read-Host "`nNew Report? (y/n)"
	if($Choice -ne "y"){break}
}

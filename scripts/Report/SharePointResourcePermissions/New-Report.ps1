# load xml data
$GroupPermissionReports = Import-Csv "GroupPermissionReports.csv" -Delimiter ";"

# resets
$Usernames = @()

# get usernames
While(1){
	$Username = Read-Host "`nEnter a username (or . to finish)"
	if($Username -eq "."){
		break
	}else{
		$Usernames += $Username	
	}
}

foreach($username in $Usernames){

	$UserGroups = .\..\..\ActiveDirectory\Report-ActiveDirectoryUserGroups.ps1 -Usernames $Username
    
    foreach ($UserGroup in $UserGroups){
    
        $GroupPermissions = $Null
	    $GroupPermissions = ($GroupPermissionReports | Where-Object {$_.Member -like $UserGroup.GroupName})
        
        Write-Progress -Activity "build report" -status $UserGroup.GroupName -percentComplete ([int]([array]::IndexOf($UserGroups, $UserGroup)/$UserGroups.Count*100))
        
        if($GroupPermissions -ne $Null){
            foreach($GroupPermission in $GroupPermissions){

                Add-Member -InputObject $GroupPermission -MemberType NoteProperty -Name "Username" -Value $Username -Force
                $GroupPermission
                
            }
        }
    }        
}
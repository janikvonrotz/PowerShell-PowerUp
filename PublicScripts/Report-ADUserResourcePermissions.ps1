
Write-Host "`nExtract Data ..."

$s1 = Create-PSSession sharepoint
# $s2 = Create-PSSession data03

# $Report1 = Invoke-Command -Session $s1 -ScriptBlock {D:\Powershell-Profile\PublicScripts\SPSecurableObjectPermissions\Report-SPSecurableObjectPermissions.ps1}
# $Report2 = Invoke-Command -Session $s2 -ScriptBlock {(C:\Powershell-Profile\PublicScripts\FileSystemPermissions\Report-FileSystemPermissions#NoDependencies.ps1 -Path "F:\Dat" -Levels 3)}
# $Report = $Report1 + $Report2


While(1){

	$Usernames = @()

	While(1){
		$Username = Read-Host "`nEnter a username (or . to finish)"
		if($Username -eq "."){
			break
		}else{
		$Usernames += $Username	
		}
	}

	$ReportUserGroups = Invoke-Command -Session $s1 -ScriptBlock {param([array]$Usernames) D:\Powershell-Profile\PublicScripts\ADUserGroups\Report-ActiveDirectoryUserGroups.ps1 -Usernames $Usernames} -ArgumentList (,$Usernames)

	#$Report | Out-GridView

	$ReportUserGroups | Out-GridView

	$Choice = Read-Host "`nNew Report? (y/n)"
	if($Choice -ne "y"){break}
}

Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black
Read-Host "`nPress Enter to exit"

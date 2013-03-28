param([Switch]$NoExit)
if($NoExit -eq $false){
	powershell -NoExit $MyInvocation.MyCommand.Definition -NoExit
}

$s1 = Create-PSSession sharepoint
$s2 = Create-PSSession data03

$ReportUserGroups = Invoke-Command -Session $s1 -ScriptBlock {(D:\Powershell-Profile\PublicScripts\ADUserGroups\Report-ActiveDirectoryUserGroups.ps1 -Usernames "vonrotz")}
$Report1 = Invoke-Command -Session $s1 -ScriptBlock {D:\Powershell-Profile\PublicScripts\SPSecurableObjectPermissions\Report-SPSecurableObjectPermissions.ps1}
$Report2 = Invoke-Command -Session $s2 -ScriptBlock {(C:\Powershell-Profile\PublicScripts\FileSystemPermissions\Report-FileSystemPermissions#NoDependencies.ps1 -Path "F:\Dat" -Levels 3)}

$Report = $Report1 + $Report2

$Report | Out-GridView

$ReportUserGroups | Out-GridView
